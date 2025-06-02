function code = train(train_dir, noise_dir, snr_db)
    k = 16;  % número de centroides

    files = dir(fullfile(train_dir, '*.wav'));
    speakers = unique(cellfun(@(f) f(8), {files.name}));  % Detecta A, D, E...

    for i = 1:length(speakers)
        speaker = speakers(i);
        speaker_files = files(contains({files.name}, ['Karate_' speaker]));

        all_v = [];

        for j = 1:length(speaker_files)
            filepath = fullfile(train_dir, speaker_files(j).name);
            [s, fs] = audioread(filepath);

            % MFCC limpio
            v_clean = mfcc(s, fs);

            % Añadir versiones ruidosas
            v_noisy = [];
            for r = 1:20
                s_noisy = addNoiseToSignal(s, fs, noise_dir, snr_db);
                v_noisy = [v_noisy, mfcc(s_noisy, fs)];
            end

            all_v = [all_v, v_clean, v_noisy];
        end

        code{i} = vqCodeBook(all_v, k);
    end
end
