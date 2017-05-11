function y = linear_blending()
  END = 35;
  file_name = [ '../ori_focal_img/1.jpg' ];
  ref = imread( file_name );
  img_size = size( ref );
  height = img_size( 1 );
  width = img_size( 2 );
  l = round( width / 8 );
  r = round( width * 3 / 8 );

  pana = ref;

  for i = 2 : END
    file_name = [ '../ori_focal_img/' int2str(i) '.jpg' ];
    img = imread( file_name );
    best = -1;
    err = 1000000000000000000.0;
    pana_size = size( pana );
    new_width = pana_size( 2 );

    for ofs = l : r
      tmp_err = 0.0;
      count = 0;
      for h = 1 : height
        for w = 1 : ofs
          new_w = new_width - ofs + w;
          for c = 1 : 3
            tmp_err = abs( img( h, w, c ) - pana( h, new_w, c ) );
          end
        end
      end
      tmp_err = tmp_err / count;
      if tmp_err < err, best = ofs; end
    end

    tmp = zeros( height, width - best, 3 );
    pana = cat( 2, pana, tmp );
    for h = 1 : height
      for w = 1 : width
          new_w = new_width - best + w;
          if w >= best
            for c = 1 : 3
              pana( h, new_w, c ) = img( h, w, c );
            end
            continue;
          end
          b = 1 - ( best - w ) / best;
          a = 1 - b;
          for c = 1 : 3
            pana( h, new_w, c ) = a * pana( h, new_w, c ) + b * img( h, w, c );
          end
      end
    end
  end
  % imshow( pana );
  imwrite( pana, './pana.jpg' );
end
