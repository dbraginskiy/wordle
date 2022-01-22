// wordle possible answers
wa:read0 `$":D:\\dev\\kdb\\wordle\\wordle-answers.txt";
// each letter scored by number of occurences in answer list
c:desc sum {count each group x} each wa; 
// wordle possible guesses & answers
wg:wa,read0 `$":D:\\dev\\kdb\\wordle\\wordle-guesses.txt";
// assign score to all words (guesses & answers) based on above score
// e.g. c distinct first wg
s:desc wg!{sum c distinct x} each wg;
// answer-only words that maximize letter frequency
// 20#desc wa!s wa
rnk:desc wa!s wa;
// now let's recommend a guess given previous guess(es)
w1:first key rnk;  // suggested first guess
// enter results of first guess from wordle
g1:("alert";00100b;00000b); // (guess word; letter present; letter in correct place)
// g:g1
guess:{[rnk; g]
    // first, filter answer list by letters in correct place using a regex
    rgx:?[g 2;g 0;"?"];
    words:key rnk;
    words:string (`$words where words like rgx) except `$(g 0);
    // next, filter for any occurrence of letters that aren't in the correct place
    words:words where (|/){x in/: words} each ((g 0) where (g 1));
    // finally, filter based on letters that are not present
    words:words where not (|/){x in/: words} each ((g 0) where not (g 1));
    // words:words where not null `$words;
    rnk:desc words!rnk words;
    rnk};
guess[rnk; g1]
// rinse and repeat...
g2:("noise";10101b;00001b);  // guess[rnk; g2]
r:guess[rnk;] each (g1;g2);
((inter/) key each r) except ()

g3:("mince";01111b;01111b);
r:guess[rnk;] each (g1;g2;g3);
((inter/) key each r) except ()


