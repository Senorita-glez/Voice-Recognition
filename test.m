function test(test_dir, code)
    files = dir(fullfile(test_dir, '*.wav'));
    files = files(~[files.isdir]);  % Ignorar carpetas

    % Recuperar nombres de locutores (si se guardó con train)
    if exist('codebooks.mat', 'file')
        data = load('codebooks.mat');
        if isfield(data, 'speakers')
            speakers = data.speakers;
        else
            % Por defecto: A, B, C...
            speakers = arrayfun(@(x) char('A'+x-1), 1:length(code), 'UniformOutput', false);
        end
    else
        speakers = arrayfun(@(x) char('A'+x-1), 1:length(code), 'UniformOutput', false);
    end


    for i = 1:length(files)
        filepath = fullfile(test_dir, files(i).name);
        try
            [s, fs] = audioread(filepath);
        catch
            fprintf('⚠️  No se pudo leer %s. Se omite.\n', files(i).name);
            continue;
        end

        if size(s,2)==2, s=mean(s,2); end  % estéreo a mono
        if isempty(s) || length(s) < fs*0.3
            fprintf('⚠️  %s es muy corto o vacío. Se omite.\n', files(i).name);
            continue;
        end

        v = mfcc(s, fs);

        if isempty(v) || any(isnan(v(:)))
            fprintf('⚠️  MFCC inválido en %s. Se omite.\n', files(i).name);
            continue;
        end

        distmin = inf;
        predicted = 0;
        dists = zeros(1, length(code));

        fprintf('\n🔍 Distancias para %s:\n', files(i).name);

        for j = 1:length(code)
            if isempty(code{j}) || any(isnan(code{j}(:)))
              fprintf('⚠️  Codebook #%d (%s) contiene NaNs o está vacío.\n', j, speakers{j});
              continue;
            end
            d = distance(v, code{j});
            dist = sum(min(d, [], 2)) / size(d,1);
            dists(j) = dist;

            fprintf('  → Codebook #%d (%s): %.4f\n', j, speakers{j}, dist);

            if dist < distmin
                distmin = dist;
                predicted = j;
            end
        end

        if predicted == 0
            fprintf('%s no pudo ser identificado (sin coincidencia clara)\n', files(i).name);
        else
            fprintf('%s identificado como speaker %s (índice %d)\n', ...
                    files(i).name, speakers{predicted}, predicted);
            endz
    end
end
