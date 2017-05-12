function y = recognizing()
  END = 18;
  file_name = [ '../recognizing_image/1.jpg' ];
  ref = imread( file_name );
  ori_img_size = size( ref );
  ori_height = ori_img_size( 1 );
  ori_width = ori_img_size( 2 );

  finalAns = zeros( 1, END );
  got = zeros( 1, END );
  finalAns( 1, 1 ) = 1;
  got( 1, 1 ) = 1;

  for i = 2 : END
    nowImage = finalAns( 1, i - 1 );
    best = -1;
    count = -1;

    for j = 1 : END
      nxtImage = j;
      if nowImage == nxtImage, continue; end
      if got( 1, nxtImage ) == 1, continue; end


      a = min( [ nowImage nxtImage ] );
      b = max( [ nowImage nxtImage ] );

      pairFile = fopen(['../offset_recognizing/' int2str(a) '_' int2str(b) ...
      '.txt' ], 'r');
      pairData = fscanf( pairFile, '%f' );
      pairData = reshape( pairData, [], 4 );
      fclose( pairFile );

      n_i = pairData( 1, 3 );
      n_f = pairData( 1, 4 );

      if nowImage > nxtImage
        pairData( 1, 2 ) = -pairData( 1, 2 );
      end

      if pairData( 1, 2 ) < 0, continue; end

      if n_i > count && n_i > 5.9 + 0.22 * n_f
        count = n_i;
        best = nxtImage;
      end
    end
    if best == -1, break; end
    got( 1, best ) = 1;
    finalAns( 1, i ) = best;
  end



  disp( finalAns );
  pana = [];
  for i = 1 : END
    if finalAns( 1, i ) <= 0, break; end
    file_name = [ '../recognizing_image/' int2str( finalAns( 1, i ) ) '.jpg' ];
    img = imread( file_name );
    pana = cat( 2, pana, img );
  end
  imshow( pana );
end
