function y = seam_carving()
  targetH = 830;
  img_name = [ '../carving/source.jpg' ];
  srcImg = imread( img_name );
  [ h, w ] = getHW( srcImg );

  while h < targetH
    disp( h );
    imshow( srcImg );
    grayImg = rgb2gray( srcImg );
    %blurredImg = imgaussfilt( grayImg, 4.5 );
    [ gMag, gDir ] = imgradient( grayImg );

    dp = zeros( h, w );
    from = zeros( h, w );
    for i = 1 : h
      dp( i, 1 ) = gMag( i, 1 );
    end
    for i = 2 : w
      for j = 1 : h
        minNeighbor = dp( j, i - 1 );
        from( j, i ) = j;
        if j > 1 && dp( j - 1, i - 1 ) < minNeighbor
          minNeighbor = dp( j - 1, i - 1 );
          from( j, i ) = j - 1;
        end
        if j < h && dp( j + 1, i - 1 ) < minNeighbor
          minNeighbor = dp( j + 1, i - 1 );
          from( j, i ) = j + 1;
        end
        dp( j, i ) = gMag( j, i ) + minNeighbor;
      end
    end

    mn = 10 ^ 18;
    idx = -1;
    for i = 1 : round( 2 * h / 3 )
      if dp( i, w ) < mn
        mn = dp( i, w );
        idx = i;
      end
    end

    path = 0;
    for i = w : -1 : 1
      if path == 0
        path = [ idx ];
      else
        path = [ idx path ];
      end
      idx = from( idx, i );
    end

    % show path
    for i = 1 : w
      srcImg( path( 1, i ), i, 1 ) = 255;
      srcImg( path( 1, i ), i, 2 ) = 0;
      srcImg( path( 1, i ), i, 3 ) = 0;
    end

    addRow = srcImg( 1, :, : );
    srcImg = [ addRow; srcImg ];

    for i = 1 : w
      for j = 1 : path( 1, i )
        srcImg( j, i, : ) = srcImg( j + 1, i, : );
      end
      if path( 1, i ) + 2 > h
        srcImg( path( 1, i ) + 1, i, : ) = srcImg( path( 1, i ), i, : );
      else
        srcImg( path( 1, i ) + 1, i, : ) = srcImg( path( 1, i ), i, : ) / 2 + ...
                                           srcImg( path( 1, i ) + 2, i, : ) / 2;
      end
    end

    [ h, w ] = getHW( srcImg );
  end

  imwrite( srcImg, '../carving/result.jpg' );
end


function [ h, w ] = getHW( picture )
  tmp = size( picture );
  h = tmp( 1 );
  w = tmp( 2 );
end
