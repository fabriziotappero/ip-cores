// this script tests the ADC encoder & decoder 
mode(-1)

// set script parameters 
// set to non zero to enable user selected WAV file 
select_file_gui = 1;
// set default file name when GUI is disabled or canceled 
default_filename = "1234.wav";
// maximum length of audio samples to limit the runtime & verilog vector files 
// set to 0 to disable any size limiting 
maximum_samp_len = 0;
// set to non zero value to enable verilog simulation input & output vectors creation 
verilog_vec_enable = 0;

// get the functions 
getd();

// set name of input WAV file 
if (select_file_gui), 
	// get file from the user 
	fname=uigetfile("*.wav", "", "Select WAV File");
	// check if default file should be used 
	if ~length(fname), 
		fname = default_filename;
	end 
else 
	// use default filename 
	fname = default_filename;
end 

// load the WAV linear samples file 
[samp, wav_Fs, wav_bits] = wavread(fname);
// only use a single channel 
samp = samp(1, :);
// number of bits must be 16 
if (wav_bits ~= 16), 
	error("ERROR: WAV file must be 16 bits.");
end 

// limit the length of the input samples vector 
if (maximum_samp_len), 
	samp = samp(1:min(maximum_samp_len, length(samp)));
end 

// call the encoder 
enc_samp = ima_adpcm_enc(samp);

// call the decoder 
dec_samp = ima_adpcm_dec(enc_samp);

// sound the result 
sound(dec_samp/max(abs(dec_samp)), wav_Fs);

// enable the following code to write Verilog simulation binary files 
if (verilog_vec_enable),
	// save the input samples to a binary file used by the verilog simulation 
	samp = round(samp * (2^15-1));
	fid = mopen("test_in.bin", "wb");
	mput(samp, "s");
	mclose(fid);
	
	// save the ADPCM encoded values 
	fid = mopen("test_enc.bin", "wb");
	mput(enc_samp, "uc");
	mclose(fid);

	// before saving the decoder samples they should be rounded using the hardware 
	// rounding implementation which only creates differences for negative .5 
	// values.
// 	round_dec_samp = round(dec_samp);
// 	cor_idx = find((round_dec_samp - dec_samp) == -0.5);
// 	round_dec_samp(cor_idx) = round_dec_samp(cor_idx) + 1;
	// save the decoded samples 
	fid = mopen("test_dec.bin", "wb");
	mput(dec_samp, "s");
	mclose(fid);
end 
