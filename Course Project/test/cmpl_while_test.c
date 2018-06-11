LET
	int a;
	int b;
	int c;
	int i;

IN
	a := 1;
	b := 2;

	read(i);

	while (i < 10)
	{
		c := a + b;
		i := i + 1;
	}

	write(a);
	write(b);
	write(c);

	return 0;
FIN