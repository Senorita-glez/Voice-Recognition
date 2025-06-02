train_dir = 'data/train/';
noise_dir = 'data/noise/';
snr = 10;

code = train(train_dir, noise_dir, snr);  % Entrenamiento
test_dir = 'data/test/';
test(test_dir, code);                     % Prueba
