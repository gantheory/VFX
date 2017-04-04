hdr = hdrread( '../data/memorial/result.hdr' );
imshow(hdr);
tonemap_p( hdr);

function rgb = tonemap_p( hdr )
    a = 0.7;
    phi = 8;
    epsilon = 0.03;
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
    imshow(rgb);
    imwrite(rgb, '../data/memorial/tonemapping1.png');
    pi = 3.1415926;

    for k = 1: 8
        s = 1 * 1.6 ^ k;
        alpha1 = 0.1;
        alpha2 = 0.1 * 1.6;
        sigma1 = s * alpha1;
        sigma2 = s * alpha2;
        V1(:,:,k) = 2 * imgaussfilt(lum, sigma1);
        V2(:,:,k) = 2 * imgaussfilt(lum, sigma2);
        
    end
  
    a = 0.5;
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
                    break;
                end
            end
        end
    end
    disp(sum);
    for i = 1: height
        for j = 1: width
            lum_d2(i, j) = 1.7*lum(i, j) / (1 + V1_new(i, j));
        end
    end

    hsv = rgb2hsv( hdr );
    hsv(:,:,3) = lum_d2;
    rgb = hsv2rgb( hsv);
    imshow(rgb)
    
    imwrite(rgb, '../data/memorial/tonemapping2.png')
    
end