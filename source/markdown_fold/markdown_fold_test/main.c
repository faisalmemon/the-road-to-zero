//
//  main.c
//  markdown_fold_test
//
//  Created by Faisal Memon on 02/10/2020.
//

#include <stdio.h>
#include "test_mfold.h"

int main(int argc, const char * argv[]) {
    test_contribution_from_tab();
    test_visual_len_with_tabs();
    test_fold_string();
    return 0;
}
