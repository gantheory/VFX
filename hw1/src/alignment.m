num_of_photos = 2;
global layer x y tmp_x tmp_y;
layer = 5;
x = 0;
y = 0;
tmp_x = 0;
tmp_y = 0;

ref = strcat('../data/memorial00','61','.png')
ref = imread( ref );
ref_g = ref( :,:,2 );
M_ref = median( ref_g );
M_ref = median( M_ref );
ref_bw = im2bw( ref_g, double( M_ref ) / 256 );
%imwrite( ref_bw, '../data/ref.png')
for i = 2 : num_of_photos
    file_name = strcat('../data/memorial00', int2str(65+i),'.png');
    tmp = imread( file_name );
    tmp = imtranslate(tmp, [31,-31]);
    
    tmp_g = tmp(:,:,2);
    M_tmp = median(tmp_g);
    M_tmp = median(M_tmp);
    tmp_bw = im2bw( tmp_g, double( M_tmp ) / 256 );
    %imwrite( tmp_bw, '../data/alignment_before.png')
    [offsetx, offsety] = recursive(ref_bw, tmp_bw, 0);
    ans = imtranslate( tmp, [offsetx, offsety] );
    imshow(ans);
    imwrite(ans, '../data/alignment.png')
end


function [ x, y ] = recursive( ref, file, cnt )
    global layer x y tmp_x tmp_y;
    cnt = cnt + 1
    
    if cnt < layer
        file_tmp = imresize( file, 0.5 );
        ref_tmp = imresize( ref, 0.5 );
        recursive( ref_tmp, file_tmp, cnt );
    end
    maxNumPixels = 0;
    x = x * 2;
    y = y * 2;
    for i = -1: 1
        for j = -1: 1
            shift = imtranslate( file, [x + i, y + j] );
            imshow(shift)
            sameColor = shift & ref;
            numPixels = sum( sameColor(:) );
            if  numPixels > maxNumPixels
                maxNumPixels = numPixels
                tmp_x = i;
                tmp_y = j;
            end
        end
    end
    x = x + tmp_x
    y = y + tmp_y
    
end


