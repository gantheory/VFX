function y = linear_blending()
  END = 10;
  file_name = [ '../warping/1.jpg' ];
  ref = imread( file_name );
  img_size = size( ref );
  height = img_size( 1 );
  width = img_size( 2 );
  disp(height);
  disp(width);
  off_prev = [0 0];

  top = 0;
  bottom = 0;
  top_c = 0;
  bottom_c = 0;
  for i = 2 : END

    file_name1 = [ '../warping/' int2str(i-1) '.jpg' ];
    img1 = imread( file_name1 );
    file_name2 = [ '../warping/' int2str(i) '.jpg' ];
    img2 = imread( file_name2 );
    file_nameoff = [ '../exhaustive_offset/' int2str(i-1) '.txt' ];
    fileID = fopen(file_nameoff);
    formatSpec = '%d';
    off = fscanf(fileID, formatSpec);
    off(2) = width - off(2);

    if (off(1) < 0)
      img1 = [img1(:, :, :); zeros(-off(1), width, 3)];
      img2 = [zeros(-off(1), width, 3); img2(:, :, :)];
    else
      img1 = [zeros(off(1), width, 3); img1(:, :, :)];
      img2 = [img2(:, :, :); zeros(off(1), width, 3)];
    end
    if off(2) + off_prev(2) - width > 0
      corr = off(2) + off_prev(2) - width;
    else corr = 0;
    end
    overlap1 = [img1(:, width - off(2) + 1 + corr: width, :)];
    overlap2 = [img2(:, 1 + corr: off(2), :) ];
    new = linear(overlap1, overlap2);
    %new = multiband(overlap1, overlap2);

    if i == 2
      para = [ img1(:, 1: width - off(2), :), new ];
      off_prev = off;
      top = top + off(1);
      bottom = bottom + off(1);
      if (top > 0)
        top = 0;
      end
      if (bottom < 0)
        bottom = 0;
      end

    else
      w = size(para);
      w = w(2);
      concat = [img1(:, off_prev(2) + 1: width - off(2), :), new];
      c = size(concat);
      if off_prev(1) > 0
        bottom_c = bottom_c + off_prev(1);
      else
        top_c = top_c + off_prev(1);
      end
      if off(1) > 0
        top_c = top_c + off(1);
      else
        bottom_c = bottom_c + off(1);
      end

      if top_c < 0
        concat = [zeros(abs(top_c), c(2), 3); concat];
      else
        top_c = 0;
      end
      if bottom_c > 0
        concat = [concat; zeros(bottom_c, c(2), 3)];
      else
        bottom_c = 0;
      end

      top = top + off(1);
      bottom = bottom + off(1);
      if top > 0
        para = [ zeros(top, w, 3); para ];
        top = 0;
      end
      if bottom < 0
        para = [ para; zeros(abs(bottom), w, 3) ];
        bottom = 0;
      end
      para = [ para, concat ];

    end
    off_prev = off;
  end
  figure
  imshow( para );
  crop( para );
end

function new = linear(overlap1, overlap2)
    sizeOver = size(overlap1);
    w1 = zeros(1, sizeOver(2));
    w2 = zeros(1, sizeOver(2));
    new = zeros( sizeOver(1), sizeOver(2), sizeOver(3) );
    start = 1;
    ending = sizeOver(2);

    for j = 1: sizeOver(2)
      black_1 = 1;
      black_2 = 1;
      for m = 1: sizeOver(1)
        for k = 1: 3
          if overlap1(m, j, k) > 10
            black_1 = 0;
          end
          if overlap2(m, j, k) > 10
            black_2 = 0;
          end
        end
      end
      if black_1 == 1 && j-1 < ending
        ending = j-1;
      elseif black_2 == 1 && j+1 > start
        start = j+1;
      end
    end
    start = start + 20;
    ending = ending - 20;
    for j = 1: sizeOver(2)
      if j < start
        w1(j) = 1;
        w2(j) = 0;
      elseif j > ending
        w1(j) = 0;
        w2(j) = 1;
      else
        w1(j) = 1 - (j-start) / (ending-start);
        w2(j) = (j-start) / (ending-start);
      end

      new(:,j,1) = w1(j) * overlap1(:, j, 1) + w2(j) * overlap2(:, j, 1);
      new(:,j,2) = w1(j) * overlap1(:, j, 2) + w2(j) * overlap2(:, j, 2);
      new(:,j,3) = w1(j) * overlap1(:, j, 3) + w2(j) * overlap2(:, j, 3);
    end
end

function new = multiband(overlap1, overlap2)
    sizeOver = size(overlap1);
    layer = 10;
    start = 1;
    ending = sizeOver(2);
    g = cell(2, layer + 1);
    lap = cell(2, layer + 1);
    newG = cell(2, layer + 1);
    newLap = cell(2, layer +1);
    w1 = zeros(1, sizeOver(2));
    w2 = zeros(1, sizeOver(2));
    for j = 1: sizeOver(2)
      black_1 = 1;
      black_2 = 1;
      for m = 1: sizeOver(1)
        for k = 1: 3
          if overlap1(m, j, k) > 10
            black_1 = 0;
          end
          if overlap2(m, j, k) > 10
            black_2 = 0;
          end
        end
      end
      if black_1 == 1 && j-1 < ending
        ending = j-1;
      elseif black_2 == 1 && j+1 > start
        start = j+1;
      end
    end
    start = start + 20;
    ending = ending - 20;
    for j = 1: sizeOver(2)
      if j < start
        overlap2(:, j, :) = overlap1(:, j, :);
      elseif j > ending
        overlap1(:, j, :) = overlap2(:, j, :);
      end
    end

    g{1, 1} = overlap1;
    g{2, 1} = overlap2;
    g1 = overlap1;
    g2 = overlap2;

    for i = 1: layer
      g1 = imgaussfilt( g1, 13/i );
      g2 = imgaussfilt( g2, 13/i );
      g1 = imresize(g1, 0.5);
      g2 = imresize(g2, 0.5);

      g{1, i+1} = g1;
      g{2, i+1} = g2;

    end
    for i = 1: layer
      sizeG = size(g{1, i});
      expandG1 = imresize(g{1, i+1}, [sizeG(1), sizeG(2)]);
      expandG2 = imresize(g{2, i+1}, [sizeG(1), sizeG(2)]);
      sizeExpandG1 = size(expandG1);
      lap{1, i} = double(g{1, i}) - double(expandG1);
      lap{2, i} = double(g{2, i}) - double(expandG2);
      a = g{1, i};
      temp = lap{1,i};

    end
    lap{1, layer + 1} = g{1, layer + 1};
    lap{2, layer + 1} = g{2, layer + 1};
    for i = 1: layer + 1
      if i == layer + 1
        a = g{1, i};
        b = g{2, i};
      else
        a = lap{1, i};
        b = lap{2, i};
      end
      sizeG = size(g{1, i});
      temp = newLap{1, i};

      for j = 1: sizeG(2)
        if j < start
          w1(j) = 1;
          w2(j) = 0;
        elseif j > ending
          w1(j) = 0;
          w2(j) = 1;
        else
          w1(j) = 1 - (j-start) / (ending-start);
          w2(j) = (j-start) / (ending-start);
        end

        temp(:,j,1) = w1(j) * a(:, j, 1) + w2(j) * b(:, j, 1);
        temp(:,j,2) = w1(j) * a(:, j, 2) + w2(j) * b(:, j, 2);
        temp(:,j,3) = w1(j) * a(:, j, 3) + w2(j) * b(:, j, 3);
      end
      newLap{1, i} = temp;

    end
    for i = layer: -1: 1
      sizeLap = size(newLap{1, i});
      if i == layer
        temp1 = imresize(newLap{1, i+1}, [sizeLap(1), sizeLap(2)]);
      else
        temp1 = imresize(newG{1, i+1}, [sizeLap(1), sizeLap(2)]);
      end
      sizeTemp = size(temp1);
      newG{1, i} = double(temp1) + double(newLap{1, i});

    end
    new = newG{1, 1};
end
function y = crop(para)
  c = 20;
  c_top = 30
  c_bottom = 155;
  para = [para(c_top:end - c_bottom, c: end-c, :)];
  imwrite( para, '../result/result.jpg' );
end
