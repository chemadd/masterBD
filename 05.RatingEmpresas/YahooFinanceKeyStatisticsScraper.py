#Importing libraries
from urllib.request import urlopen
import pandas as pd
import time
from random import randint

# READING THE CASE YAHOO TICKER SAMPLE LIST!
df = pd.read_excel("https://www.dropbox.com/s/2x1rmt2ma96j2my/yahoo_ticker_sample.xlsx?dl=1")

# LIST OF FIELDS WE WILL SCRAPE
list_of_fields = ['Market Cap', 'Enterprise Value', 'Trailing P/E', 'Forward P/E', 'PEG Ratio', 'Price/Sales', 'Price/Book', 'Enterprise Value/Revenue', 'Enterprise Value/EBITDA', 'Fiscal Year Ends', 'Most Recent Quarter', 'Profit Margin', 'Operating Margin', 'Return on Assets', 'Return on Equity', 'Revenue', 'Revenue Per Share', 'Quarterly Revenue Growth', 'Gross Profit', 'EBITDA', 'Net Income Avi to Common', 'Diluted EPS', 'Quarterly Earnings Growth', 'Total Cash', 'Total Cash Per Share', 'Total Debt', 'Total Debt/Equity', 'Current Ratio', 'Book Value Per Share', 'Operating Cash Flow', 'Levered Free Cash Flow', 'Beta', '52-Week Change', 'S&amp;P500 52-Week Change', '52 Week High', '52 Week Low', '50-Day Moving Average', '200-Day Moving Average', 'Avg Vol (3 month)', 'Avg Vol (10 day)', 'Shares Outstanding', 'Float', '% Held by Insiders', '% Held by Institutions', 'Shares Short', 'Short Ratio', 'Short % of Float', 'Shares Short (prior month)', 'Forward Annual Dividend Rate', 'Forward Annual Dividend Yield', 'Trailing Annual Dividend Rate', 'Trailing Annual Dividend Yield', '5 Year Average Dividend Yield', 'Payout Ratio', 'Dividend Date', 'Ex-Dividend Date', 'Last Split Factor', 'Last Split Date']
list_of_dates = ['Fiscal Year Ends', 'Most Recent Quarter', 'Dividend Date', 'Ex-Dividend Date', 'Last Split Date']

# CREATING EMPTY FIELD IN THE DATA FRAME FOR RECORDING THE SCRAPED DATA.
for i in range(len(list_of_fields)):
    df[list_of_fields[i]] = ''
df['ScrapedName'] = ''
df['Sector'] = ''


# MAIN LOOK - SCRAPPING DATA - FOR EACH TICKER IN THE df
error = 0
for j in range(len(df)):    
#    print ("ticker =", df['ticker'][j],j, " de ", len(df))    
   
    stock = df['ticker'][j]

    # REQUESTING INFORMATION FROM YAHOO AND INSISTING IF DOES NOT RESPOND - STOPPING THE PROGRAM IF YAHOO DOES NOT REPLY FOR TWO tickers IN SEQUENCE!
    try:
        sourceCode = str(urlopen('https://finance.yahoo.com/quote/'+stock+'/key-statistics?p='+stock).read())
        error = 0
    except:
        time.sleep(randint(1,12))
        try:
            sourceCode = str(urlopen('https://finance.yahoo.com/quote/'+stock+'/key-statistics?p='+stock).read())
            error = 0
        except:
            if error == 0:
                time.sleep(randint(10,100))
                error = 1
                continue
            else:
                break

    # FINDING COMPANY NAME IN YAHOO PAGE TO MAKE SURE WE GETTING THE CORRECT COMPANY - COMPANY NAME IS EASY TO FIND.
    compname= sourceCode.split('Find out all the key statistics for')[1].split(', including')[0]
    if compname.find('{shortName} ({symbol})') >= 0:
        continue   
    df['ScrapedName'].iloc[j] = compname           

    # YAHOO FINANCE HAS 2 WAYS OF OPENING AND CLOSING TAGS </td></tr> OR </span></td></tr>, SO WE REMOVE THE </span> TO MAKE THEM ALL THE SAME:
    sourceCode = sourceCode.replace('</span>','')
    
    for field in list_of_fields:
        ScrapedValue = sourceCode.split('>' + field)[1].split('</td></tr>')[0].split('>')[-1]
#        print ("field=",field, " / scraped valued= ", ScrapedValue)

        df[field].iloc[j] = ScrapedValue

    # ALSO GRABBING COMPANY SECTOR FROM YAHOO PAGE.
    try:
        ScrapedSector = ''
        sourceCode = str(urlopen('https://finance.yahoo.com/quote/'+stock+'/profile?p='+stock).read())
        ScrapedAux = sourceCode.split('>Sector')[1].split('</strong>')[0].split('>')
        ScrapedSector = ScrapedAux[len(ScrapedAux)-1]
        df['Sector'].iloc[j] = ScrapedSector
    except:
        True
    print ("ticker =", df['ticker'][j], "company name =", compname,"sector=",ScrapedSector,j, " de ", len(df))

# SAVING TO EXCEL ALL SCRAPED  DATA!
df.to_excel("yahoo_ticker_sample_scraped.xlsx")



 