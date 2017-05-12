function y = msop()
  END = 18;
  file_name = [ '../recognizing_image/1.jpg' ];
  ref = imread( file_name );
  ori_img_size = size( ref );
  ori_height = ori_img_size( 1 );
  ori_width = ori_img_size( 2 );
  fx = [ -1 0 1 ];
  fy = [ -1; 0; 1 ];
  rs8 = 1 / sqrt( 8 );
  rs2 = 1 / sqrt( 2 );
  H = [ rs8  rs8  rs8  rs8  rs8  rs8  rs8  rs8;
        rs8  rs8  rs8  rs8 -rs8 -rs8 -rs8 -rs8;
        0.5  0.5 -0.5 -0.5    0    0    0    0;
          0    0    0    0  0.5  0.5 -0.5 -0.5;
        rs2 -rs2    0    0    0    0    0    0;
          0    0  rs2 -rs2    0    0    0    0;
          0    0    0    0  rs2 -rs2    0    0;
          0    0    0    0    0    0  rs2 -rs2;];

  for numOfImage = 1 : END
    file_name = [ '../recognizing_image/' int2str(numOfImage) '.jpg' ];
    disp( file_name );
    img = imread( file_name );
    photo = rgb2gray( img );

    subSample = photo;
    for level = 1 : 4
      disp( size( subSample ) );

      img_size = size( subSample );
      height = img_size( 1 );
      width = img_size( 2 );
      scale = 2 ^ ( level - 1 );

      Ix = filter2( fx, subSample );
      Iy = filter2( fy, subSample );

      Ix2 = Ix .^ 2;
      Iy2 = Iy .^ 2;
      Ixy = Ix .* Iy;

      G = fspecial( 'gaussian', [ 7, 7 ], 1.0 );
      Sx2 = filter2( G, Ix2 );
      Sy2 = filter2( G, Iy2 );
      Sxy = filter2( G, Ixy );

      for h = 1 : height
        for w = 1 : width
          M = [ Sx2( h, w ) Sxy( h, w ); Sxy( h, w ) Sy2( h, w ) ];
          R( h, w ) = det( M ) / trace( M );
        end
      end

      blurredImg = imgaussfilt( subSample, 4.5 );
      [ Gx, Gy] = imgradientxy( blurredImg );
      [ gMag, gDir ] = imgradient( Gx, Gy );

      r = 6;
      count_points = 1;
      for h = 1 : height
        for w = 1 : width
          if h * scale > ori_height || w * scale > ori_width
            continue;
          end
          if R( h, w ) >= 10.0
            flag = 1;
            for i = h - r : h + r
              if flag == 0, break; end
              for j = w - r : w + r
                if i == h && j == w, continue; end
                if i < 1 || i > height || j < 1 || j > width, continue; end
                if R( h, w ) < R( i, j )
                  flag = 0;
                  break;
                end
              end
            end
            for i = h - r * scale : h + r * scale
              if flag == 0, break; end
              for j = w - r * scale : w + r * scale
                if i == h && j == w, continue; end
                if i < 1 || i > ori_height || j < 1 || j > ori_width, continue; end
                if img( i, j, 1 ) == 255
                  flag = 0;
                  break;
                end
              end
            end
            % find if there exists a 40 * 40 window
            tmpFeatureWindow = zeros( 40, 40 );
            if flag == 1
              dx = cos( gDir( h, w ) / 180.0 * pi );
              dy = sin( gDir( h, w ) / 180.0 * pi );
              sx = int16( w - 20 * dx );
              sy = int16( h - 20 * dy );
              for i = 1 : 40
                for j = 1 : 40
                  nowx = int16( sx + i * dx );
                  nowy = int16( sy + j * dy );
                  if nowx < 1 || nowx > width || nowy < 1 || nowy > height
                    flag = 0;
                    break;
                  end
                  tmpFeatureWindow( j, i ) = subSample( nowy, nowx );
                end
                if flag == 0, break; end
              end
            end
            % write feature vectors to the file
            finalFeatureWindow = zeros( 8, 8 );
            if flag == 1
              for i = 1 : 8
                for j = 1 : 8
                  avgValue = 0.0;
                  si = ( i - 1 ) * 5;
                  sj = ( j - 1 ) * 5;
                  for k = si + 1 : si + 5
                    for l = sj + 1 : sj + 5
                      avgValue = avgValue + tmpFeatureWindow( k, l );
                    end
                  end
                  avgValue = avgValue / 25.0;
                  finalFeatureWindow( i, j ) = avgValue;
                end
              end
              finalFeatureWindow = transpose( H ) * finalFeatureWindow * H;
              feature_file = fopen( ['../msop_recognizing/' int2str( numOfImage ) '.txt'], 'a' );
              fprintf( feature_file, '%d ', h * scale );
              fprintf( feature_file, '%d ', w * scale );
              for i = 1 : 8
                for j = 1 : 8
                  fprintf( feature_file, '%f ', finalFeatureWindow( i, j ) );
                end
              end
              fprintf( feature_file, '\n' );
              fclose( feature_file );
            end
            if flag == 1
              img( h * scale, w * scale, 1 ) = 255;
              img( h * scale, w * scale, 2 ) = 0;
              img( h * scale, w * scale, 3 ) = 0;
            end
          end
        end
      end

      subSample = impyramid( subSample, 'reduce' );
    end

    num = 0;
    flag = zeros( ori_height, ori_width );
    for h = 1 : ori_height
      for w = 1 : ori_width
        if img( h, w, 1 ) == 255 && img( h, w, 2 ) == 0 && img( h, w, 3 ) == 0
          num = num + 1;
          flag( h, w ) = 1;
        end
      end
    end
    for h = 1 : ori_height
      for w = 1 : ori_width
        if flag( h, w ) == 1
          for i = h - 1 : h + 1
            for j = w - 1 : w + 1
              if  i < 1 || i > ori_height || j < 1 || j > ori_width
                continue;
              end
              img( i, j, 1 ) = 255;
              img( i, j, 2 ) = 0;
              img( i, j, 3 ) = 0;
            end
          end
        end
      end
    end
    disp( [ 'points: ' int2str( num ) ] );
    disp( size( img ) );
    imwrite( img, ['../msop_recognizing/' int2str( numOfImage ) '.jpg'] );
  end
end
