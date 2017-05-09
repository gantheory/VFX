function y = warp()
  END = 35;
  file_name = [ '../input_image/1.JPG' ];
  ref = imread( file_name );
  img_size = size( ref );
  height = img_size( 1 );
  width = img_size( 2 );
  photos = zeros( END, height, width, 3 );

  pana = []
  for i = 1 : END
    file_name = [ '../input_image/' int2str(i) '.JPG' ];
    img = imread( file_name );
    tmp = img;
    for h = 1 : height
      for w = 1 : width
        for c = 1 : 3
          img( h, w, c ) = 0;
        end
      end
    end

    f = 400.0;
    for h = 1 : height
      for w = 1 : width
        x = round( h - height / 2 );
        y = round( w - width / 2 );

        new_x = f * x / sqrt( y^2 + f^2 );
        new_y = f * atan( y / f );

        new_x = round( new_x + height / 2 );
        new_y = round( new_y + width / 2 );

        for c = 1 : 3
          img( new_x, new_y, c ) = tmp( h, w, c );
        end
      end
    end

    imwrite( img, ['../warping_img/' int2str(i) '.jpg'] );
    pana = cat( 2, pana, img );
  end
  % imwrite( pana, './pana.jpg' );
end
