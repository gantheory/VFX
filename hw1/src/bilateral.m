hdr = hdrread('../result_robertson.hdr');
foo = size( hdr );
height = foo( 1 );
width = foo( 2 );
intensity = zeros( height, width, 3 );
log_intensity = zeros( height, width );
log_base = zeros( height, width );
color = zeros( height, width, 3 );

colorSigma = 0.2;
spatialSigma = 0.02 * min( height, width );

for i = 1 : height
  for j = 1 : width
    for c = 1 : 3
      intensity( i, j, c ) = 0.212671 * hdr( i, j, 1 ) + 0.71516 * hdr( i, j, 2 ) + 0.072169 * hdr( i, j, 3 );
      log_intensity( i, j ) = log( intensity( i, j, 1 ) );
      color( i, j, c ) = hdr( i, j, c ) / intensity( i, j, 1 );
    end
  end
end

hdrwrite( intensity, '../intensity.hdr' );
hdrwrite( color, '../color.hdr' ); 

% calculating log_base
% bilateralFilter( log_intensity, log_base, colorSigma, spatialSigma );
disp( 'calculating log_base' );
cs = colorSigma;
ss = spatialSigma;
two_cs2 = 2 * cs * cs;
two_ss2 = 2 * ss * ss;
three_ss = 3 * ss;
qx_max = 0;
qx_min = 0;
qy_max = 0;
qy_min = 0;

for py = 1 : height 
  for px = 1 : width
    wp = 0;
    log_base( py, px ) = 0;
		% filtering
		qy_min = round( py - three_ss );
		qx_min = round( px - three_ss );
		qy_max = round( py + three_ss );
		qx_max = round( px + three_ss );
		for qy = qy_min : qy_max
      if qy <= 0
        continue;
      end
      if qy > height
        break;
      end
      for qx = qx_min : qx_max
        if qx <= 0
          continue;
        end
        if qx > width
          break;
        end
        space2 = ( px - qx ) ^ 2 + ( py - qy ) ^ 2;
        range = log_intensity( py, px ) - log_intensity( qy, qx ); 
				w = exp(-space2 / two_ss2) * exp(-(range * range) / two_cs2);
				log_base( py, px) = log_base( py, px ) + w * log_intensity( qy, qx );
				wp = wp + w;
      end
		end
    log_base( py, px ) = log_base( py, px ) / wp;
  end
end

% calculating detail in log domain
disp( 'calculating detail in log domain' );
log_detail = zeros( height, width );
for i = 1 : height 
  for j = 1 : width
    log_detail( i, j ) = log_intensity( i, j ) - log_base( i, j );
  end
end

% get max & min log_base
disp( 'get max & min log_base' );
maxLogBase = log_base( 1, 1 );
minLogBase = log_base( 1, 1 );
for i = 1 : height
  for j = 1 : width
    if maxLogBase < log_base( i, j )
      maxLogBase = log_base( i, j );
    end
    if minLogBase > log_base( i, j )
      minLogBase = log_base( i, j )
    end
  end
end

% contrast reduction init
disp( 'contrast reduction unit' );
targetContrast = 5.0
compressionFactor = log( targetContrast ) / ( maxLogBase - minLogBase );
absoluteScale = maxLogBase * compressionFactor;

% contrast reduction
disp( 'contrast reduction' );
maxLogIntensity = -100000.0
minLogIntensity = 100000.0
contrastReduced = zeros( height, width );
for i = 1 : height
  for j = 1 : width
		contrastReduced( i, j ) = log_base( i, j ) * compressionFactor + log_detail( i, j ) - absoluteScale;
    if ( contrastReduced( i, j ) > maxLogIntensity )
      maxLogIntensity = contrastReduced( i, j );
    end
    if ( contrastReduced( i, j ) < minLogIntensity )
      minLogIntensity = contrastReduced( i, j );
    end
  end
end
for i = 1 : height
  for j = 1 : width
    contrastReduced( i, j ) = exp( 1 ) ^ ( contrastReduced( i, j ) );
  end
end

% recovering the result
disp( 'recovering the result' );
result = zeros( height, width, 3 );
for i = 1 : height
  for j = 1 : width
    for c = 1 : 3
      % modify gamma, 1.0 => 1.0 / 1.6 
      result( i, j, c ) = ( contrastReduced( i, j ) * color( i, j, c ) ) ^ ( 1.0 );
    end
  end
end

% clamping the result
disp( 'clamping the result' );
for i = 1 : height
  for j = 1 : width
    for c = 1 : 3
      if result( i, j, c ) > 255
        result( i, j, c ) = 255;
      end
      if result( i, j, c ) < 0
        result( i, j, c ) = 0;
      end
    end
  end
end

imwrite( result, '../self_tonemapping.png' );
