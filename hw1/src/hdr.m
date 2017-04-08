% params
start = 63;
num_of_photos = 11;
height = 768;
width = 512;
photos = zeros(num_of_photos, height, width, 3);
N = 11;

% read files
disp( 'reading file...' );
for i = 1 : num_of_photos
    file_name = ['../data/memorial/memorial00' int2str( i + start - 1 ) '.png'];
    tmp = imread( file_name );
    disp( file_name );
    for j = 1 : height
        for k = 1 : width
            for l = 1 : 3
                photos(i, j, k, l) = tmp(j, k, l);
            end
        end
    end
end

% initialize inputs of gsolve.m
rZ = zeros(N * N, num_of_photos);
gZ = zeros(N * N, num_of_photos);
bZ = zeros(N * N, num_of_photos);
B = zeros( 1, num_of_photos );
lambda = 1.0; % usually between 1.0 ~ 5.0
w = zeros( 1, 256 );

disp( 'randomly picking points...' );
x = rand( 1, N );
y = rand( 1, N );
for i = 1 : N
  x( 1, i ) = round( ( x( 1, i ) + 1 ) * width / 2 );
end
for i = 1 : N
  y( 1, i ) = round( ( y( 1, i ) + 1 ) * height / 2 );
end

disp( 'initalizing...' );
% gray scale: ( 54R + 183G + 19B ) / 256
disp( 'Z...' );
for j = 1 : num_of_photos  
  for pos_y = 1 : N 
    for pos_x = 1 : N 
      rZ( pos_x + ( pos_y - 1 ) * N, j ) = photos( j, y( 1, pos_y ), x( 1, pos_x ), 1 ); 
      gZ( pos_x + ( pos_y - 1 ) * N, j ) = photos( j, y( 1, pos_y ), x( 1, pos_x ), 2 ); 
      bZ( pos_x + ( pos_y - 1 ) * N, j ) = photos( j, y( 1, pos_y ), x( 1, pos_x ), 3 ); 
    end
  end
end
disp( 'B...' );
init_t = 1 / 0.125;
for j = 1 : num_of_photos
  B( j ) = log( init_t );
  init_t = init_t / 2;
end
disp( 'w...' );
for z = 0 : 127
  idx = z + 1;
  w( idx ) = z + 1;
  w( 257 - idx ) = z + 1;
end

% get the response curve
[ rg, lE ] = gsolve( rZ, B, lambda, w );
[ gg, lE ] = gsolve( gZ, B, lambda, w );
[ bg, lE ] = gsolve( bZ, B, lambda, w );

% reduce noise
disp( 'reducing noise...' );
rlE = zeros( 1, width * height );
glE = zeros( 1, width * height );
blE = zeros( 1, width * height );
max_E = zeros( 1, 3 );
for x = 1 : width
  for y = 1 : height 
    i = x + ( y - 1 ) * width;
    w_sum = 0.0;
    E = 0.0;
    for j = 1 : num_of_photos
      Zij = photos( j, y, x, 1 ) + 1;
      w_sum = w_sum + w( Zij );
      E = E + w( Zij ) * ( rg( Zij ) - B( j ) );  
    end
    if E > max_E( 1, 1 )
      max_E( 1, 1 ) = E;
    end
    rlE( 1, i ) = E / w_sum;
  end
end
for x = 1 : width
  for y = 1 : height 
    i = x + ( y - 1 ) * width;
    w_sum = 0.0;
    E = 0.0;
    for j = 1 : num_of_photos
      Zij = photos( j, y, x, 2 ) + 1;
      w_sum = w_sum + w( Zij );
      E = E + w( Zij ) * ( gg( Zij ) - B( j ) );  
    end
    if E > max_E( 1, 2 )
      max_E( 1, 2 ) = E;
    end
    glE( 1, i ) = E / w_sum;
  end
end
for x = 1 : width
  for y = 1 : height 
    i = x + ( y - 1 ) * width;
    w_sum = 0.0;
    E = 0.0;
    for j = 1 : num_of_photos
      Zij = photos( j, y, x, 3 ) + 1;
      w_sum = w_sum + w( Zij );
      E = E + w( Zij ) * ( bg( Zij ) - B( j ) );  
    end
    if E > max_E( 1, 3 )
      max_E( 1, 3 ) = E;
    end
    blE( 1, i ) = E / w_sum;
  end
end
for i = 1 : 3 
  max_E( 1, i ) = exp( max_E( 1, i ) );
end

result_hdr = zeros( height, width, 3 );
for y = 1 : height
  for x = 1 : width
    i = x + ( y - 1 ) * width;
    result_hdr( y, x, 1 ) = exp( rlE( 1, i ) );
  end
end
for y = 1 : height
  for x = 1 : width
    i = x + ( y - 1 ) * width;
    result_hdr( y, x, 2 ) = exp( glE( 1, i ) );
  end
end
for y = 1 : height
  for x = 1 : width
    i = x + ( y - 1 ) * width;
    result_hdr( y, x, 3 ) = exp( blE( 1, i ) );
  end
end

% result_hdr = hdrread( '../data/memorial.hdr' );
% disp( result_hdr );

hdrwrite( result_hdr, '../result.hdr' );

result_png = tonemap( result_hdr );
imwrite( result_png, '../result.png' );
