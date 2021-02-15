`SWREG_W(KNN_RESET,     1, 0)
`SWREG_W(KNN_FINISHED_DATASET,  1, 0)
`SWREG_R(KNN_CALCULATING_CLASS, 1, 0) // Asserting 1 while hardware is calculating the class, software should not access KNN_CLASS while this registers is asserted

`SWREG_W(KNN_DATASET_XY,    32, 0)     // Set the dataset XY position
`SWREG_W(KNN_DATASET_CLASS,  3, 0)     // Set the class it belongs to

`SWREG_BANKW(KNN_DATAPOINT, 32, 0, 16) // Send X,Y together
`SWREG_BANKR(KNN_CLASS,      3, 0, 16) // Get the resulting class