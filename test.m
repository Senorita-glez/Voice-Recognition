function test(test_dir, code)
    files = dir(fullfile(test_dir, '*.wav'));

    for i = 1:length(files)
        filepath = fullfile(test_dir, files(i).name);
        [s, fs] = audioread(filepath);
        v = mfcc(s, fs);

        distmin = inf;
        predicted = 0;

        for j = 1:length(code)
            d = distance(v, code{j});
            dist = sum(min(d, [], 2)) / size(d, 1);
            if dist < distmin
                distmin = dist;
                predicted = j;
            end
        end

        fprintf('%s identificado como speaker %d\\n', files(i).name, predicted);
    end
end