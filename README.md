# Postfix Expression Evaluation

In implementarea proiectului, am abordat urmatoarea metoda:
1. Calculez mai intai lungimea expresiei
2. Evaluez expresia caracter cu caracter (labelul evaluate_expression) in care:
a) Daca am gasit un spatiu, inseamna ca acel nu este de interes, deci ma mut pe
urmatorul caracter care cu siguranta va exista (nu avem spatiu ca ultim caracter
in expresie);
b) Daca am gasit "+", trebuie sa efectuez adunarea, extrag de pe stiva operanzii
in ordine inversa, efectuez adunarea si pun rezultatul inapoi pe stiva;
c) Daca am gasit "*", trebuie sa efectuez produsul, procedez analog ca la adunare;
d) Daca am gasit "/", trebuie sa efectuez impartirea, analog ca la adunare;
e) Daca am gasit "-", pot exista 2 situatii:
	* Am intalnit un numar negativ, deci verific caracterele urmatoare pana
	  intalnesc spatiu (labelul parse_negative), dupa care neg numarul pozitiv
          de dupa "-" si il adaug pe stiva (labelul push_negative_number);
	* Am de efectuat o operatie de scadere, atunci cand dupa "-" gasesc un
          spatiu sau nu mai gasesc alt caracter (sunt la finalul expresiei); in
	  acest caz procedez analog ca la adunare;
f) Daca am gasit un numar, verific caracterele urmatoare pana intalnesc spatiu
(labelul check_number), dupa care il adaug pe stiva (labelul push_number);
3. La finalul evaluarii expresiei, va ramane pe stiva rezultatul acesteia; ii dau
pop si il afisez.
