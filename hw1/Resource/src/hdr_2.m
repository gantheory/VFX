% params
start = 86;
num_of_photos = 1;

iteration = 7;
file_name = ['../input_image/DSC04886.JPG'];
ref = imread(file_name);
img_size = size(ref);
height = img_size(1);
width = img_size(2);
photos = zeros(num_of_photos, height, width, 3);
w = zeros(num_of_photos, height * width, 3);
t = zeros(1, num_of_photos);
init_t = 1 / 60;
for j = 1 : num_of_photos
  t(j) = init_t ;
  init_t = init_t * 2;
end

% read files
disp( 'reading file...' );
for i = 1 : num_of_photos
    disp(i);
    if (i < 10)
        file_name = ['../input_image/DSC048' int2str( i + start - 1 ) '.JPG'];
    else 
        file_name = ['../input_image/DSC)48' int2str( i + start - 1 ) '.JPG'];
    end
    
    tmp = imread( file_name );
    imshow(tmp);
    
    N = height * width;
    disp( file_name );
    for j = 1 : height 
        for w = 1: width 
            for k = 1 : 3
                photos(i, j, w, k) = tmp( j, w ,k);
            end
        end
    end
    
end
photos = reshape(photos, num_of_photos, height * width, 3);


disp('read_finish');


w = exp(-4 /(127.5^2) * (photos - 127.5).^2);
I = zeros( 256, 3);
disp('finish');
for i = 1: 256
    for k = 1: 3
        I(i, k) = 1 * i / 128;
    end
end

for iter = 1: iteration
    disp('iteration');
    x = zeros(height * width, 3);
    for k = 1: 3
        for j = 1: N
            a = 0;
            b = 0;
            for i = 1: num_of_photos          
                a = a + w(i, j, k) * t(i) * I(photos(i, j, k)+1, k);
                b = b + w(i, j, k) * (t(i)^2);

            end
            x(j, k) = double(a) / double(b);
  
        end
    end
    card = zeros(256, 3);
    for m = 1: 256
        for k = 1: 3
            I(m ,k) = 0;
            for i = 1: num_of_photos
                for j = 1: N
                    if photos(i, j, k) + 1 == m 
                        card(m, k) = card(m, k) + 1;
                        I(m, k) = I(m, k) + t(i) * x(j, k);
                    end
                end
            end
            if card(m, k) ~= 0
                I(m,k) = I(m,k) / card(m,k);
            end
        end
    end
    obj = 0;
    for k = 1: 3
        for i = 1: num_of_photos
            for j = 1: N
                obj = obj + w(i, j, k) * (I(photos(i, j, k)+1, k) - t(i) * x(j, k))^2;
            end
        end
    end
    disp(obj)
    obj = 0;
    
end
result_hdr = zeros( height, width, 3 );
x = reshape(x, height, width, 3);
for i = 1: height
    for j = 1: width
        for k = 1: 3
            for m = 1: 255
                if x(i, j, k) > I(m, k) && x(i, j, k) < I(m+1, k)  
                    result_hdr(i, j, k) = m;
                    break;
                elseif x(i, j, k) > I(255, k)
                    result_hdr(i ,j , k) = 255;
                elseif  x(i, j, k) < I(1, k)
                    result_hdr(i ,j , k) = 0;
                end
            end    
        end
    end
end
hdrwrite( result_hdr, '../result/shannon.hdr')
result_png = tonemap( result_hdr );
imwrite( result_png, '../shannon.png' );


