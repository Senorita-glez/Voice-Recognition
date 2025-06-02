train_dir = 'data/train/';
test_dir = 'data/test/';
noise_dir = 'data/noise/';
snr = 10;

code = train(train_dir, noise_dir, snr);
test(test_dir, code);
