import datetime, time, vim

# Calc the date interval of (endDate - startDate)
# startDate: string looks like: 20170827
# endDate  : string looks like: 20170827
# return   : date interval. And return value for vim is in b:pyRet.
def PyDateDiffer(startDate, endDate):
    timeS = time.strptime(vim.eval(startDate),"%Y%m%d")
    timeE = time.strptime(vim.eval(endDate),"%Y%m%d")
    pyStartDate = datetime.datetime(timeS[0],timeS[1],timeS[2],timeS[3],timeS[4],timeS[5])
    pyEndDate   = datetime.datetime(timeE[0],timeE[1],timeE[2],timeE[3],timeE[4],timeE[5])
    differ = (pyEndDate - pyStartDate).days

    b = vim.current.buffer
    b.vars["pyRet"] = differ
    return differ

def PyDateAdd(startDate, addDays, outFormat):
    timeS = time.strptime(vim.eval(startDate),"%Y%m%d")
    pyStartDate = datetime.datetime(timeS[0],timeS[1],timeS[2],timeS[3],timeS[4],timeS[5])
    delta = datetime.timedelta(days=addDays)
    toDate = pyStartDate + delta

    b = vim.current.buffer
    if outFormat == '%Y-%m-%d':
        ret = toDate.strftime('%Y-%m-%d')
        b.vars["pyRet"] = ret
    else:
        ret = toDate.strftime('%Y%m%d')
        b.vars["pyRet"] = ret
    #b.vars["pyRet"] = differ
