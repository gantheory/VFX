function y = warp()
  END = 18;
  file_name = [ '../input_image2/1.jpg' ];
  ref = imread( file_name );
  img_size = size( ref );
  height = img_size( 1 );
  width = img_size( 2 );
  photos = zeros( END, height, width, 3 );

  for i = 1 : END
    numOfImage = i;
    file_name = [ '../input_image2/' int2str(numOfImage) '.jpg' ];
    img = imread( file_name );
    tmp = img;
    for h = 1 : height
      for w = 1 : width
        for c = 1 : 3
          img( h, w, c ) = 0;
        end
      end
    end

    f = 600.0;
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

    imwrite( img, ['../warping/' int2str(i) '.jpg'] );

    inputFile = fopen( [ '../msop/' int2str(i) '.txt' ], 'r' );
    inputData = fscanf( inputFile, '%f' );
    inputData = reshape( inputData, 66, [] );
    outputFile = fopen( [ '../warping/' int2str(i) '.txt' ], 'w' );
    tmp = size( inputData );
    sz = tmp( 2 );
    for i = 1 : sz
      h = inputData( 1, i );
      w = inputData( 2, i );
      x = round( h - height / 2 );
      y = round( w - width / 2 );

      new_x = f * x / sqrt( y^2 + f^2 );
      new_y = f * atan( y / f );

      new_x = round( new_x + height / 2 );
      new_y = round( new_y + width / 2 );

      fprintf( outputFile, '%d ', new_x );
      fprintf( outputFile, '%d ', new_y );

      for j = 3 : 66
        fprintf( outputFile, '%d ', inputData( j, i ) );
      end
      fprintf( outputFile, '\n' );
    end
    fclose( outputFile );
    fclose( inputFile );
  end
end
