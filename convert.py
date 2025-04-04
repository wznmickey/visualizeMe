import pandas as pd
import numpy as np

def csv_clean(file):
    data = pd.read_csv(file)
    # file = file.dropna()
    # file = file.drop_duplicates()
    # print(file)
    data= data[["Product","Process Size (nm)","TDP (W)","Die Size (mm^2)"]]
    data = data.dropna()
    print(data)
    data.to_csv('cleaned_chip_dataset.csv', index=False, header=False)
csv_clean('chip_dataset.csv')