function code = train(train_dir, noise_dir, snr_db)
    k = 16;                % Número de centroides por codebook
    num_ruidos = 20;       % Cambia a 5 o 10 si estás depurando

    files = dir(fullfile(train_dir, '*.wav'));
    if isempty(files)
        error('No se encontraron archivos en %s', train_dir);
    end

    % Extraer iniciales únicas (A, D, E, etc.)
    speakers = unique(cellfun(@(f) f(8), {files.name}));

    for i = 1:length(speakers)
        speaker = speakers(i);
        fprintf('\nProcesando locutor %s (índice %d)\n', speaker, i);

        % Filtrar archivos de ese locutor
        speaker_files = files(contains({files.name}, ['Karate_' speaker]));
        if isempty(speaker_files)
            fprintf('No se encontraron archivos para el locutor %s. Se omite.\n', speaker);
            continue;
        end

        all_v = [];
        tic;

        for j = 1:length(speaker_files)
            file_path = fullfile(train_dir, speaker_files(j).name);
            fprintf('  [%d/%d] Procesando archivo: %s\n', j, length(speaker_files), speaker_files(j).name);
            [s, fs] = audioread(file_path);

            if size(s,2) == 2, s = mean(s,2); end  % estéreo a mono
            if isempty(s) || length(s) < fs * 0.5
                fprintf('    ⚠️ Archivo omitido por duración insuficiente o vacío.\n');
                continue;
            end

            % MFCC limpio
            v_clean = mfcc(s, fs);

            % Añadir versiones ruidosas
            v_noisy = [];
            for r = 1:num_ruidos
                try
                    s_noisy = addNoise(s, fs, noise_dir, snr_db);
                    if any(isnan(s_noisy)) || any(isinf(s_noisy))
                        warning('    ⚠️ Ruido inválido (NaN/Inf), omitiendo...');
                        continue;
                    end
                    v_noisy = [v_noisy, mfcc(s_noisy, fs)];
                catch err
                    warning('    ⚠️ Error al aplicar ruido: %s', err.message);
                    continue;
                end
            end

            % Combinar MFCCs limpio + ruidosos
            all_v = [all_v, v_clean, v_noisy];
        end

        % Entrenar codebook para este locutor
        fprintf('→ Entrenando codebook (%d vectores)...\n', size(all_v, 2));
        code{i} = vqCodeBook(all_v, k);

        elapsed = toc;
        fprintf('✅ Codebook generado para locutor %s en %.2f s (índice %d)\n', ...
                speaker, elapsed, i);
    end

    % Guardar los codebooks entrenados (opcional)
    save('codebooks.mat', 'code');
    fprintf('\n✅ Todos los codebooks se guardaron en "codebooks.mat"\n');
end
