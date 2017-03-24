num_of_photos = 4;
height = 2112;
width = 2816;
photos = zeros(num_of_photos, height, width, 3);
for i = 1 : num_of_photos
    file_name = ['../data/img_' int2str( i ) '.jpeg'];
    tmp = imread( file_name );
    disp( file_name );
    disp( size( tmp ) );
    for j = 1 : height
        for k = 1 : width
            for l = 1 : 3
                photos(i, j, k, l) = tmp(j, k, l);
            end
        end
    end
end

Z = zeros(height * width, num_of_photos)
