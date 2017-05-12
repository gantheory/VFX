function y = ransac_recognizing()
  END = 18;
  file_name = [ '../input_image2/1.jpg' ];
  ref = imread( file_name );
  ori_img_size = size( ref );
  ori_height = ori_img_size( 1 );
  ori_width = ori_img_size( 2 );

  for nowImage = 1 : END
    for nxtImage = nowImage + 1 : END
      pairFile = fopen( ['../exhaustive_recognizing/' int2str(nowImage) ...
        '_' int2str( nxtImage ) '.txt'], 'r' );
      pairData = fscanf( pairFile, '%d' );
      pairData = reshape( pairData, 4, [] );
      fclose( pairFile );
      tmp = size( pairData );
      pairSz = tmp( 2 );

      offsetX = 0;
      offsetY = 0;

      match = 0;
      outlier = 0;
      for K = 1 : 200
        rnd = int16( rand * ( pairSz - 1 ) + 1 );
        tmpOffsetX = pairData( 2, rnd ) - pairData( 4, rnd );
        tmpOffsetY = pairData( 1, rnd ) - pairData( 3, rnd );

        tmpMatch = 0;
        tmpOutlier = 0;
        for i = 1 : pairSz
          nowX = pairData( 4, i ) + tmpOffsetX;
          nowY = pairData( 3, i ) + tmpOffsetY;
          dst = ( nowX - pairData( 2, i ) ) ^ 2 + ( nowY - pairData( 1, i ) ) ^ 2;
          if dst <= 100
            tmpMatch = tmpMatch + 1;
          end
          if nowX < ori_width && nowX > tmpOffsetX && dst > 100
            tmpOutlier = tmpOutlier + 1;
          end
        end

        if tmpMatch > match
          offsetX = tmpOffsetX;
          offsetY = tmpOffsetY;
          match = tmpMatch;
          outlier = tmpOutlier;
        end
      end
      disp( [ 'offset: ' int2str( offsetX ) ' ' int2str( offsetY ) ] );
      disp( [ 'match points: ' int2str( match ) ' ' int2str( outlier ) ] );
      disp( pairSz );

      offsetFile = fopen( ['../offset_recognizing/' int2str(nowImage) '_' int2str(nxtImage) '.txt'], 'w' );
      fprintf( offsetFile, '%d ', offsetY );
      fprintf( offsetFile, '%d ', offsetX );
      fprintf( offsetFile, '%d ', match );
      fprintf( offsetFile, '%d\n', outlier );
      fclose( offsetFile );
    end
  end
end
