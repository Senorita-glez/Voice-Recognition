function code = train(train_dir, noise_dir, snr_db)
    k = 16;  % número de centroides

    files = dir(fullfile(train_dir, '*.wav'));
    speakers = unique(cellfun(@(f) f(8), {files.name}));
    total = length(files);

    h = waitbar(0, 'Entrenando codebooks...');
    step = 0;

    for i = 1:length(speakers)
        speaker = speakers(i);
        speaker_files = files(contains({files.name}, ['Karate_' speaker]));
        all_v = [];

        for j = 1:length(speaker_files)
            step = step + 1;
            filepath = fullfile(train_dir, speaker_files(j).name);
            fprintf('[%d/%d] Procesando archivo: %s\\n', step, total, speaker_files(j).name);

            waitbar(step/total, h, sprintf('Procesando %s (%d/%d)', speaker_files(j).name, step, total));
            drawnow;

            [s, fs] = audioread(filepath);
            v_clean = mfcc(s, fs);

            v_noisy = [];
            for r = 1:20
                try
                    s_noisy = addNoise(s, fs, noise_dir, snr_db);
                    v_noisy = [v_noisy, mfcc(s_noisy, fs)];
                catch ME
                    fprintf('  ⚠️  Error al añadir ruido (%s): %s\\n', speaker_files(j).name, ME.message);
                end
            end

            all_v = [all_v, v_clean, v_noisy];
        end

        code{i} = vqCodeBook(all_v, k);
        fprintf('✅ Codebook generado para locutor %s (índice %d)\\n', speaker, i);
    end

    close(h);
end