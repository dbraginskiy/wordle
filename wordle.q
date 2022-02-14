// wordle possible answers
wa:read0 `$":D:\\dev\\kdb\\wordle\\wordle-answers.txt";
// each letter scored by number of occurences in answer list
c:desc sum {count each group x} each wa; 
// wordle possible guesses & answers (not that useful - commenting out)
// wg:wa,read0 `$":D:\\dev\\kdb\\wordle\\wordle-guesses.txt";
// assign score to all words (guesses & answers) based on above score
// s:desc wg!{sum c distinct x} each wg;
s:desc wa!{sum c distinct x} each wa;
// answer-only words that maximize letter frequency
// 20#desc wa!s wa
rnk:desc wa!s wa;
// now let's recommend a guess given previous guess(es)
w1:first key rnk;  // suggested first guess
// g:g1
guess1:{[rnk; g]
    words:key rnk;
    // if we guessed anything at all
    if[(|/) g 1;[
        // first, filter answer list by letters in correct place using a regex
        rgx:?[g 2;g 0;"?"];
        words:string (`$words where words like rgx) except `$(g 0);
        // filter for letters that aren't in the correct place (but still present)
        words:words where (&/){x in/: y}[;words] each ((g 0) where (g 1));
        // also need to ensure these aren't repeated in same (incorrect) position
        // letter (ltr) in string (s) cannot appear in same location
        rgxs:{[s;ltr] ?[s=ltr;ltr;"?"]}[g 0;] each (g 0) where (g 1)<>(g 2);
        words:{[w;rgx]
            w:w where not w like rgx;
            w}/[words;rgxs];
    ]];
    // finally, filter based on letters that are not present
    words:words where not (|/){x in/: y}[;words] each ((g 0) where not (g 1));
    // words:words where not null `$words;
    rnk:desc words!rnk words;
    rnk};

// gs:(g1;g2;g3;g4;g5)
guess:{[rnk;gs]
    gs:gs where (count each gs)>0;
    r:guess1[rnk;] each gs;
    r:((inter/) key each r) except ();
    r!rnk r};

// (guess word; letter present; letter in correct place)
g1:("alert";01000b;00000b); 
g2:("solid";01100b;00000b);
g3:();
g4:();
g5:();

guess[rnk;(g1;g2;g3;g4;g5)]
