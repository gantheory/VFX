function y = ransac()
  END = 17;

  for numOfImage = 1 : END
    pairFile = fopen( ['../match_pair/' int2str(numOfImage) '.txt'], 'r' );
    pairData = fscanf( pairFile, '%d' );
    pairData = reshape( pairData, 4, [] );
    tmp = size( pairData );
    pairSz = tmp( 2 );

    offsetX = 0;
    offsetY = 0;

    match = 0;
    for K = 1 : 500
      rnd = int16( rand * ( pairSz - 1 ) + 1 );
      tmpOffsetX = pairData( 2, rnd ) - pairData( 4, rnd );
      tmpOffsetY = pairData( 1, rnd ) - pairData( 3, rnd );
      while tmpOffsetX < 0
        rnd = int16( rand * ( pairSz - 1 ) + 1 );
        tmpOffsetX = pairData( 2, rnd ) - pairData( 4, rnd );
        tmpOffsetY = pairData( 1, rnd ) - pairData( 3, rnd );
      end

      tmpMatch = 0;
      for i = 1 : pairSz
        nowX = pairData( 4, i ) + tmpOffsetX;
        nowY = pairData( 3, i ) + tmpOffsetY;
        dst = ( nowX - pairData( 2, i ) ) ^ 2 + ( nowY - pairData( 1, i ) ) ^ 2;
        if dst <= 100
          tmpMatch = tmpMatch + 1;
        end
      end

      if tmpMatch > match
        offsetX = tmpOffsetX;
        offsetY = tmpOffsetY;
        match = tmpMatch;
      end
    end
    disp( [ offsetX offsetY ] );
    disp( [ match pairSz ] );

    offsetFile = fopen( ['../offset/' int2str(numOfImage) '.txt'], 'w' );
    fprintf( offsetFile, '%d ', offsetY );
    fprintf( offsetFile, '%d ', offsetX );
    fclose( offsetFile );
  end
end
