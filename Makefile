all:
	dmd -wi -of"genetica" "genetica.d"

clean:
	rm -rf *.o genetica
