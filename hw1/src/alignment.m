num_of_photos = 11;
global layer x y tmp_x tmp_y;
layer = 5;
x = 0;
y = 0;
tmp_x = 0;
tmp_y = 0;

ref = strcat('../data/1/img','01','.JPG')
ref = imread( ref );
ref_g = ref( :,:,2 );
M_ref = median( ref_g );
M_ref = median( M_ref );
ref_bw = im2bw( ref_g, double( M_ref ) / 256 );
%imwrite( ref_bw, '../data/ref.png')
for i = 2 : num_of_photos
    if i < 10
        file_name = strcat('../data/1/img0', int2str(i),'.JPG');
    else 
        file_name = strcat('../data/1/img', int2str(i),'.JPG');
    end
    tmp = imread( file_name );
    %tmp = imtranslate(tmp, [30,-30]);
    
    tmp_g = tmp(:,:,2);
    M_tmp = median(tmp_g);
    M_tmp = median(M_tmp);
    tmp_bw = im2bw( tmp_g, double( M_tmp ) / 256 );
    %imwrite( tmp_bw, '../data/alignment_before.png')
    [offsetx, offsety] = recursive(ref_bw, tmp_bw, 0);
    ans = imtranslate( tmp, [offsetx, offsety] );
    %imshow(ans);
    if i < 10
        output = strcat('../data/1/align_img0', int2str(i),'.JPG')
    else 
        output = strcat('../data/1/align_img', int2str(i),'.JPG')
    end
    imwrite(ans, output)
end


function [ x, y ] = recursive( ref, file, cnt )
    global layer x y tmp_x tmp_y;
    cnt = cnt + 1
    if cnt == 1
        x = 0;
        y = 0;
    end
    
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


