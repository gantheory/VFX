function y = exhaustive_match()
  END = 17;
  file_name = [ '../input_image/1.JPG' ];
  ref = imread( file_name );
  ori_img_size = size( ref );
  ori_height = ori_img_size( 1 );
  ori_width = ori_img_size( 2 );

  for nowImage = 1 : END
    file_name = fopen([ '../msop/' int2str( nowImage ) '.txt' ], 'r');
    prvData = fscanf( file_name, '%f' );
    prvData = reshape( prvData, 66, [] );
    fclose( file_name );
    for nxtImage = nowImage + 1 : END
      file_name = fopen([ '../msop/' int2str( nxtImage ) '.txt' ], 'r');
      nowData = fscanf( file_name, '%f' );
      nowData = reshape( nowData, 66, [] );
      fclose( file_name );

      tmp = size( prvData );
      prvSz = tmp( 2 );
      tmp = size( nowData );
      nowSz = tmp( 2 );

      pairFile = fopen( ['../exhaustive/' int2str( nowImage ) '.txt'], 'w' );
      num = 0;
      prvPair = 0;
      nowPair = 0;
      for p = 1 : prvSz
        bestN = -1;
        errN = 10 ^ 18;
        for n = 1 : nowSz
          if abs( prvData( 1, p ) - nowData( 1, n ) ) > 10, continue; end
          tmpErr = sum( ( prvData( 3 : 66, p ) - nowData( 3 : 66, n ) ) .^ 2 );
          if tmpErr < errN
            bestN = n;
            errN = tmpErr;
          end
        end

        bestP = -1;
        errP = 10 ^ 18;
        if bestN == -1, continue; end
        for pp = 1 : prvSz
          if abs( prvData( 1, pp ) - nowData( 1, bestN ) ) > 10, continue; end
          tmpErr = sum( ( prvData( 3 : 66, pp ) - nowData( 3 : 66, bestN ) ) .^ 2 );
          if tmpErr < errP
            bestP = pp;
            errP = tmpErr;
          end
        end

        if bestP == p
          fprintf( pairFile, '%d ', prvData( 1, bestP ) );
          fprintf( pairFile, '%d ', prvData( 2, bestP ) );
          fprintf( pairFile, '%d ', nowData( 1, bestN ) );
          fprintf( pairFile, '%d\n', nowData( 2, bestN ) );
          num = num + 1;
          if prvPair == 0
            prvPair = [ prvData( 2, bestP ) prvData( 1, bestP ) ];
            nowPair = [ nowData( 2, bestN ) nowData( 1, bestN ) ];
          else
            prvPair = [ prvPair; prvData( 2, bestP ) prvData( 1, bestP ) ];
            nowPair = [ nowPair; nowData( 2, bestN ) nowData( 1, bestN ) ];
          end
        end
      end
      disp( ['match points: ' int2str( num )] );
      fclose( pairFile );

      img1 = imread( ['../warping/' int2str(nowImage) '.jpg'] );
      img2 = imread( ['../warping/' int2str(nxtImage) '.jpg'] );
      figure; ax = axes;
      showMatchedFeatures( img1, img2, prvPair, nowPair, 'montage','Parent',ax);
      break;
    end
  end
end
