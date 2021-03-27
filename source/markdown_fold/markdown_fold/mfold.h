//
//  mfold.h
//  markdown_fold
//
//  Created by Faisal Memon on 02/10/2020.
//

#ifndef mfold_h
#define mfold_h

#include <stdio.h>
#include <stdlib.h>

enum {
    TAB_LENGTH = 8,
    WIDTH = 65,
};

void
usage(void);

size_t
contribution_from_tab(size_t col, int tab_length);

size_t
visual_len_with_tabs(char *source, int tab_length);

void
fold_string(char *string, int width, int tab_length);

int
parse(FILE *fin, int width, int tab_length);

#endif /* mfold_h */
