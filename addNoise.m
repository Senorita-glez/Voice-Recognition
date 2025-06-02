function s_noisy = addNoise(s, fs, noise_dir, snr_db)
    noise_files = dir(fullfile(noise_dir, '*.wav'));
    if isempty(noise_files)
        error('No se encontraron archivos .wav en la carpeta %s', noise_dir);
    end

    idx = randi(length(noise_files));
    noise_file = fullfile(noise_dir, noise_files(idx).name);
    [noise, fs_noise] = audioread(noise_file);
    noise = mean(noise, 2); 

    if fs ~= fs_noise
        noise = resample(noise, fs, fs_noise);
    end

    if length(noise) < length(s)
        noise = repmat(noise, ceil(length(s)/length(noise)), 1);
    end
    noise = noise(1:length(s));

    signal_power = mean(s.^2);
    noise_power = mean(noise.^2);
    scaling_factor = sqrt(signal_power / (10^(snr_db/10) * noise_power));
    noise_scaled = noise * scaling_factor;

    s_noisy = s + noise_scaled;
end
