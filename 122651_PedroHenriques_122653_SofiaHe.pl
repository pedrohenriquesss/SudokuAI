sudoku(Tabuleiro, Solution) :- insere_com_verificacao(Tabuleiro, Solution), valida_sudoku(Solution). 

imprime_sudoku([]).
imprime_sudoku([Linha1, Linha2, Linha3 | Resto]) :- 
    imprime_linha(Linha1), nl, % imprime a primeira linha
    imprime_linha(Linha2), nl, % imprime a segunda linha
    imprime_linha(Linha3), nl, % imprime a terceira linha
    write('---------------------------'), nl, % separa os blocos
    imprime_sudoku(Resto).

imprime_linha([]). 
imprime_linha([A, B, C | Resto]) :- 
    write(A), write(' '), write(B), 
    write(' '), write(C), write(' | '), % imprime 3 números com separação nos blocos
    imprime_linha(Resto).

% valida se o número está entre 1 e 9
numero_valido(N) :- intervalo(1, 9, N).

% gera o intervalo de números de L a H
intervalo(L, H, L) :- L =< H.
intervalo(L, H, X) :- L < H, L1 is L+1, intervalo(L1, H, X).

% insere números válidos no tabuleiro de Sudoku verificando-os
insere_com_verificacao([], []).
insere_com_verificacao([Linha|Resto], [NovaLinha|NovaResto]) :- 
    insere_linha_com_verificacao(Linha, NovaLinha), % insere números numa linha com verificação
    valida_linha(NovaLinha), % valida a linha inserida
    insere_com_verificacao(Resto, NovaResto). % insere nas outras linhas

% insere números válidos nas posições vazias (0), verificando-os
insere_linha_com_verificacao([], []).
insere_linha_com_verificacao([0|T], [N|NT]) :- numero_valido(N), 
    nao_pertence(N, T), % número dentro do intervalo e que ainda não esteja na linha
    insere_linha_com_verificacao(T, NT). % preenche o resto da linha
insere_linha_com_verificacao([H|T], [H|NT]) :- H \= 0, nao_pertence(H, T), 
    insere_linha_com_verificacao(T, NT). % se for diferente de 0, e não estiver na linha, insere

nao_pertence(_, []).
nao_pertence(X, [Y|T]) :- X \= Y, nao_pertence(X, T). % verifica que o número não existe na lista

% valida uma linha, garantindo que não haja números repetidos
valida_linha([]).
valida_linha([0|T]) :- valida_linha(T). % ignora os espaços vazios (0)
valida_linha([H|T]) :- 
    H \= 0, nao_pertence(H, T), % se o número não for 0, verifica que não se repete
    valida_linha(T).

transposta([[]|_], []).
transposta(Matriz, [H|T]) :- 
    transposta_coluna(Matriz, H, RestoMatriz), % extrai a primeira coluna
    transposta(RestoMatriz, T).

% extrai uma coluna de uma matriz
transposta_coluna([], [], []).
transposta_coluna([[H|T]|Resto], [H|Coluna], [T|RestoMatriz]) :- transposta_coluna(Resto, Coluna, RestoMatriz).

% gera um bloco 3x3 de uma matriz, dada a posição X Y
bloco(Matriz, X, Y, Bloco) :- 
    findall(Elem, (intervalo(0, 2, I), intervalo(0, 2, J), % gera índices para os 9 elementos do bloco
        RowIndex is X*3+I, ColIndex is Y*3+J,
        get_row(Matriz, RowIndex, Row), get_element(Row, ColIndex, Elem)), Bloco).

get_row([H|_], 0, H).
get_row([_|T], N, Row) :- N > 0, N1 is N-1, get_row(T, N1, Row).

get_element([H|_], 0, H).
get_element([_|T], N, Elem) :- N > 0, N1 is N-1, get_element(T, N1, Elem).

% valida um Sudoku, verificando todas as linhas, colunas e blocos
valida_sudoku(Matriz) :- 
    valida_todas_linhas(Matriz), transposta(Matriz, Transposta),
    valida_todas_linhas(Transposta), % valida as colunas, depois de calcular a transposta
    valida_todos_blocos(Matriz).

valida_todas_linhas([]).
valida_todas_linhas([H|T]) :- valida_linha(H), valida_todas_linhas(T).

valida_todos_blocos(Matriz) :- valida_blocos_aux(Matriz, 0, 0).

valida_blocos_aux(_, 3, _). % caso base: quando já validou todas os blocos
valida_blocos_aux(Matriz, X, 3) :- 
    X1 is X + 1, valida_blocos_aux(Matriz, X1, 0). % avança para a próxima linha
valida_blocos_aux(Matriz, X, Y) :- bloco(Matriz, X, Y, Bloco), % obtém o bloco 3x3
    valida_linha(Bloco), % valida o bloco
    Y1 is Y + 1, valida_blocos_aux(Matriz, X, Y1).