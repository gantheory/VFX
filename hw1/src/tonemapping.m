hdr = hdrread( '../result.hdr' );
tonemap_p( hdr);

function rgb = tonemap_p( hdr )
    a = 0.7;
    phi = 1;
    epsilon = 0.0005;
    lum_w = 0.27 * hdr(:,:,1) + 0.67 * hdr(:,:,2) + 0.06 * hdr(:,:,3);
    image_size = size( hdr );
    height = image_size(1);
    width = image_size(2);
    N = height * width;
    sum_all = 0;
   
    for i = 1: height
        for j = 1: width
            sum_all = sum_all + log( 0.00000001+ lum_w(i, j) );
        end
    end
    lum_white = max( lum_w(:) );
    %lum_white = 1e20;
    lum_w_bar = double( exp (sum_all / N) );
    
    lum = a / lum_w_bar * lum_w;
    for i = 1: height
        for j = 1: width
            lum_d(i, j) = lum(i, j) * ( 1 + lum(i, j) / lum_white / lum_white ) / (1 + lum(i, j) );
        end
    end
    
    hsv = rgb2hsv( hdr );
    hsv(:,:,3) = lum_d;
    rgb = hsv2rgb( hsv);
    imshow(rgb)
    imwrite(rgb, '../tonemapping1.png')
    sum = 0;
    pi = 3.1415926;
    sum2 = 0;
    for k = 1: 8 
        sum = 0;
        sum2 = 0;
        for i = 1: height
            for j = 1: width        
                s = 1 * 1.6 ^ k;
                alpha1 = 0.35;
                alpha2 = 0.35 * 1.6;
                sigma1 = s * alpha1;
                sigma2 = s * alpha2;
               
                R1(i, j, k) = exp( -( i ^ 2 + j ^ 2) / ( sigma1 ^ 2) ) / ( pi * ( sigma1 ^ 2 ) ); 
                R2(i, j, k) = exp( -( i ^ 2 + j ^ 2) / ( sigma2 ^ 2 ) ) / ( pi * ( sigma2 ^ 2 ) );
                sum = sum + R1(i, j, k); 
                sum2 = sum2+R2(i, j, k);
            end
        end
        R1(:,:,k) = R1(:,:,k) / sum;
        R2(:,:,k) = R2(:,:,k) / sum2;
    end
    disp(sum);
    disp(sum2);
    for k = 1: 8
        fft_lum = fft( lum );
        fft_R1(:,:,k) = fft( R1(:,:,k));
        fft_R2(:,:,k) = fft( R2(:,:,k));
        fft_V1(:,:,k) = fft_lum .* fft_R1(:,:,k);
        fft_V2(:,:,k) = fft_lum .* fft_R2(:,:,k);
       
        V1(:,:,k) = ifft(fft_V1(:,:,k));
        V2(:,:,k) = ifft(fft_V2(:,:,k));
    end
    %imshow(V1(:,:,1))
    %imshow(V2(:,:,8))
    for i = 1: height
        for j = 1: width
            for k = 1:8
                V(i, j, k) = ( V1(i, j, k) - V2(i, j, k)) / ((2 ^ phi) * a / ((1.6 ^ k) ^ 2) + V1(i, j, k));
                
            end
        end
    end
    sum = 0;
    for i = 1: height
        for j = 1: width
            V1_new(i, j) = 0;
            for k = 1:8            
                if abs(V(i, j, k)) < epsilon
                    V1_new(i, j) = V1(i, j, k);   
                    sum = sum + 1;
                    
                end
            end
        end
    end
    disp(sum);
    for i = 1: height
        for j = 1: width
            lum_d2(i, j) = lum(i, j) / (1 + V1_new(i, j));
            
        end
    end
    hsv = rgb2hsv( hdr );
    hsv(:,:,3) = lum_d2;
    rgb = hsv2rgb( hsv);
    imshow(rgb)
    imwrite(rgb, '../tonemapping2.png')
    
end