LET
	int a;
	int b;
	int c;
	int d;
	int i;

IN
	a := 1;
	b := 2;

	read(i);
	read(c);

	while (i < 10) {
		if (a < c)
		{
			d := a + c;
		} else {
			d := a - c;
		}
		i := i + 1;
	}

	write(a);
	write(b);
	write(c);

	return 0;
FIN