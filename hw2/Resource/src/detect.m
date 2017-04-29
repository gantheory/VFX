function y = detect()
  END = 35;
  file_name = [ '../input_image/1.JPG' ];
  ref = imread( file_name );
  img_size = size( ref );
  height = img_size( 1 );
  width = img_size( 2 );
  photos = zeros( END, height, width );
  Ix = zeros( END, height, width );
  Iy = zeros( END, height, width );
  Sxx = zeros( END, height, width );
  Sxy = zeros( END, height, width );
  Syy = zeros( END, height, width );
  R = zeros( END, height, width );
  result = zeros( END, height, width );

  for i = 1 : END
    file_name = [ '../input_image/' int2str(i) '.JPG' ];
    img = imread( file_name );
    photos( i, :, : ) = rgb2gray( img );
  end

  % compute Ix and Iy
  disp( 'computing Ix and Iy' );
  for i = 1 : END
    for h = 1 : height
      for w = 2 : width
        Ix( i, h, w ) = photos( i, h, w ) - photos( i, h, w - 1 );
      end
      Ix( i, 1, w ) = Ix( i, 2, w );
    end
  end
  for i = 1 : END
    for w = 1 : width
      for h = 2 : height
        Iy( i, h, w ) = photos( i, h, w ) - photos( i, h - 1, w );
      end
      Iy( i, 1, w ) = Iy( i, 2, w );
    end
  end

  % compute Ixx, Ixy, and Iyy
  disp( 'computing Ixx, Ixy, and Iyy' );
  Ixx = Ix .* Ix;
  Ixy = Ix .* Iy;
  Iyy = Iy .* Iy;
  clear Ix;
  clear Iy;

  % compute SOP derivatives of each pixel
  disp( 'computing Sxx, Sxy, and Syy' );
  G = fspecial( 'gaussian', [ 7, 7 ], 2 );
  for i = 1 : END
    Sxx( i, :, : ) = filter2( G, reshape( Ixx( i, :, : ), [ height, width ] ) );
    Sxy( i, :, : ) = filter2( G, reshape( Ixy( i, :, : ), [ height, width ] ) );
    Syy( i, :, : ) = filter2( G, reshape( Iyy( i, :, : ), [ height, width ] ) );
  end

  disp( 'computing the response of the detector' );
  R_max = 0.0;
  k = 0.05; % empirical constant, 0.04 ~ 0.06
  for i = 1 : END
    for h = 1 : height
      for w = 1 : width
        M = [ Sxx( i, h, w ) Sxy( i, h, w ); Sxy( i, h, w ) Syy( i, h, w ) ];
        R( i, h, w ) = det(M) - 0.05 * (trace(M))^2;
        if R( i, h, w ) > R_max
          R_max = R( i, h, w );
        end
      end
    end
  end

  disp( 'filter some R by the threshold and nonmax suppresion' );
  for i = 1 : END
    for h = 2 : height - 1
      for w = 2 : width - 1
        if R( i, h, w ) > 0.005 * R_max && ...
          R( i, h, w ) > R( i, h - 1, w ) && ...
          R( i, h, w ) > R( i, h - 1, w + 1 ) && ...
          R( i, h, w ) > R( i, h, w + 1 ) && ...
          R( i, h, w ) > R( i, h + 1, w + 1 ) && ...
          R( i, h, w ) > R( i, h + 1, w ) && ...
          R( i, h, w ) > R( i, h + 1, w - 1 ) && ...
          R( i, h, w ) > R( i, h, w - 1 ) && ...
          R( i, h, w ) > R( i, h -1, w - 1 )
          result( i, h, w ) = 255;
        end
      end
    end
  end

  for i = 1 : END
    imwrite( reshape( result( i, : , : ), [ height, width ] ),...
    [ '../feature_img/' int2str(i) '.gif' ] );
  end
end
