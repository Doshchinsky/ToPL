LET
	int a;
	int b;
	int c;
	int d;

IN
	a := 1;
	b := 2;

	read(c);

	if (a < c)
	{
		d := a + c;
	} else {
		d := a - c;
	}

	write(a);
	write(b);
	write(c);

	return 0;
FIN