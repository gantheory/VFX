function y = hash_match()
  END = 18;
  file_name = [ '../input_image2/1.jpg' ];
  ref = imread( file_name );
  ori_img_size = size( ref );
  ori_height = ori_img_size( 1 );
  ori_width = ori_img_size( 2 );

  for numOfImage = 1 : END - 1
    prv = numOfImage;
    nxt = numOfImage + 1;

    featureFile = fopen(['../warping/' int2str(prv) '.txt'],'r');
    prvData = fscanf( featureFile, '%f' );
    prvData = reshape( prvData, 66, [] );

    featureFile = fopen(['../warping/' int2str(nxt) '.txt'],'r');
    nxtData = fscanf( featureFile, '%f' );
    nxtData = reshape( nxtData, 66, [] );

    prvBins = cell( 10, 10, 10 );
    nxtBins = cell( 10, 10, 10 );
    for i = 1 : 10
      for j = 1 : 10
        for k = 1 : 10
          prvBins{ i, j, k } = {};
          nxtBins{ i, j, k } = {};
        end
      end
    end

    tmp = size( prvData );
    prvSz = tmp( 2 );
    tmp =size( nxtData );
    nxtSz = tmp( 2 );

    for i = 1 : prvSz
      prvData( 1, i ) = int32( prvData( 1, i ) );
      prvData( 2, i ) = int32( prvData( 2, i ) );
    end
    for i = 1 : nxtSz
      nxtData( 1, i ) = int32( nxtData( 1, i ) );
      nxtData( 2, i ) = int32( nxtData( 2, i ) );
    end

    mx = zeros( 1, 3 );
    mn = zeros( 1, 3 );
    for i = 1 : 3
      mn( 1, i ) = 10 ^ 18;
    end

    % ( 0, 1 ) ( 1, 1 ) ( 1, 0 )
    % 3, 9, 10
    mp = [ 4 11 12 ];
    for i = 1 : 3
      nowIndex = mp( 1, i );
      for j = 1 : prvSz
        if prvData( nowIndex, j ) > mx( 1, i )
          mx( 1, i ) = prvData( nowIndex, j );
        end
        if prvData( nowIndex, j ) < mn( 1, i )
          mn( 1, i ) = prvData( nowIndex, j );
        end
      end
      for j = 1 : nxtSz
        if nxtData( nowIndex, j ) > mx( 1, i )
          mx( 1, i ) = nxtData( nowIndex, j );
        end
        if nxtData( nowIndex, j ) < mn( 1, i )
          mn( 1, i ) = nxtData( nowIndex, j );
        end
      end
    end

    for i = 1 : prvSz
      pos = zeros( 1, 3 );
      for j = 1 : 3
        pos( 1, j ) = prvData( mp( 1, j ), i );
        pos( 1, j ) = ( pos( 1, j ) - mn( 1, j ) ) / ...
                      ( mx( 1, j ) - mn( 1, j ) );
        pos( 1, j ) = int32( pos( 1, j ) * 10 ) + 1;
        if pos( 1, j ) > 10, pos( 1, j ) = 10; end
      end
      a = pos( 1, 1 );
      b = pos( 1, 2 );
      c = pos( 1, 3 );

      prvBins{ a, b, c } = [ prvBins{ a, b, c }, i ];
    end

    for i = 1 : nxtSz
      pos = zeros( 1, 3 );
      for j = 1 : 3
        pos( 1, j ) = nxtData( mp( 1, j ), i );
        pos( 1, j ) = ( pos( 1, j ) - mn( 1, j ) ) / ...
                      ( mx( 1, j ) - mn( 1, j ) );
        pos( 1, j ) = int32( pos( 1, j ) * 10 ) + 1;
        if pos( 1, j ) > 10, pos( 1, j ) = 10; end
      end
      a = pos( 1, 1 );
      b = pos( 1, 2 );
      c = pos( 1, 3 );

      nxtBins{ a, b, c } = [ nxtBins{ a, b, c }, i ];
    end

    prvPair = 0;
    nxtPair = 0;
    num = 0;
    for i = 1 : 10
      for j = 1 : 10
        for k = 1 : 10
          [ zzz, pSz ] = size( prvBins{ i, j, k } );
          [ zzz, nSz ] = size( nxtBins{ i, j, k } );
          prvMat = cell2mat( prvBins{ i, j, k } );
          nxtMat = cell2mat( nxtBins{ i, j, k } );
          for p = 1 : pSz
            bestN = -1;
            first = -1;
            second = -1;
            nowP = prvMat( 1, p );
            for n = 1 : nSz
              nowN = nxtMat( 1, n );
              err = 0.0;
              for foo = 1 : 3
                err = err + ( prvData( mp( 1, foo ), nowP ) - ...
                              nxtData( mp( 1, foo ), nowN ) ) ^ 2;
              end
              if first == -1
                bestN = nowN;
                first = err;
              elseif second == -1
                if err < first
                  second = first;
                  first = err;
                  bestN = nowN;
                else
                  second = err;
                end
              elseif err < first
                second = first;
                first = err;
                bestN = nowN;
              elseif err < second
                second = err;
              end
            end
            if bestN == -1, continue; end

            GG = 0;
            bestP = -1;
            firstP = -1;
            secondP = -1;

            for pp = 1 : pSz
              nowPP = prvMat( 1, pp );
              err = 0.0;
              for foo = 1 : 3
                err = err + ( prvData( mp( 1, foo ), nowPP ) - ...
                              nxtData( mp( 1, foo ), bestN ) ) ^ 2;
              end
              if firstP == -1
                bestP = nowPP;
                firstP = err;
              elseif secondP == -1
                if err < firstP
                  secondP = firstP;
                  firstP = err;
                  bestP = nowPP;
                else
                  secondP = err;
                end
              elseif err < firstP
                secondP = firstP;
                firstP = err;
                bestP = nowPP;
              elseif err < secondP
                secondP = err;
              end
            end
            if bestP ~= nowP, continue; end

            if ( first ~= -1 && second == -1 ) || first / second <= 0.65 ...
                || first == second
              if abs( prvData( 1, nowP ) - nxtData( 1, bestN ) ) > 10, continue; end
              num = num + 1;
              if prvPair == 0
                prvPair = [ prvData( 2, nowP ) prvData( 1, nowP ) ];
                nxtPair = [ nxtData( 2, bestN ) nxtData( 1, bestN ) ];
              else
                prvPair = [ prvPair; prvData( 2, nowP ) prvData( 1, nowP ) ];
                nxtPair = [ nxtPair; nxtData( 2, bestN ) nxtData( 1, bestN ) ];
              end
            end
          end
        end
      end
    end

    disp(['feature matched points: ' int2str( num )]);

    img1 = imread( ['../warping/' int2str(prv) '.jpg'] );
    img2 = imread( ['../warping/' int2str(nxt) '.jpg'] );
    %figure; ax = axes;
    %showMatchedFeatures( img1, img2, prvPair, nxtPair, 'montage','Parent',ax);

    pairFile = fopen(['../match_pair/' int2str(prv) '.txt'], 'w');
    for i = 1 : num
      fprintf( pairFile, '%d ', prvPair( i, 2 ) );
      fprintf( pairFile, '%d ', prvPair( i, 1 ) );
      fprintf( pairFile, '%d ', nxtPair( i, 2 ) );
      fprintf( pairFile, '%d\n', nxtPair( i, 1 ) );
    end
    fclose( pairFile );

  end
end
