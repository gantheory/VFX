hdr = hdrread('../result.hdr');
foo = size( hdr );
height = foo( 1 );
width = foo( 2 );
intensity = zeros( height, width, 3 );
log_intensity = zeros( height, width );
color = zeros( height, width, 3 );

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
