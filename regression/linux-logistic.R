#
# Linux-logistic.R, 23 Apr 20
# Data from:
# The {Linux} Kernel as a Case Study in Software Evolution
# Ayelet Israeli and Dror G. Feitelson
#
# Example from:
# Evidence-based Software Engineering: based on the publicly available data
# Derek M. Jones
#
# TAG Linux_LOC LOC_evolution

source("ESEUR_config.r")


pal_col=rainbow(2)


ll=read.csv(paste0(ESEUR_dir, "regression/Linux-LOC.csv.xz"), as.is=TRUE)
ld=read.csv(paste0(ESEUR_dir, "regression/Linux-days.csv.xz"), as.is=TRUE)


loc_date=merge(ll, ld)

loc_date$Release_date=as.Date(loc_date$Release_date, format="%d-%b-%Y")
start_date=loc_date$Release_date[1]

loc_date$MLOC=loc_date$LOC/1e6
loc_date$Number_days=as.integer(difftime(loc_date$Release_date,
                                         start_date,
                                         units="days"))

ld_ordered=loc_date[order(loc_date$Release_date), ]

strip_support_v=function(version_date, step)
{
v=substr(version_date$Version, 1, 3)
q=c(rep(TRUE, step), v[1:(length(v)-step)] <= v[(1+step):length(v)])
return (version_date[q, ])
}



h1=strip_support_v(ld_ordered, 1)
all_days=strip_support_v(h1, 5)

# If 3000 is used the following error appears:
# step factor 0.000488281 reduced below 'minFactor' of 0.000976562
# This is probably due to the initial values chosen, it is
# simpler to include a few more points than fiddle around with tuning value.
first_3000=subset(all_days, Number_days <= 3400)

x_bounds=0:6000

plot(all_days$Number_days, all_days$MLOC, col=pal_col[2],
	xaxs="i", yaxs="i",
	xlim=range(x_bounds),
	xlab="Days since version 1.0 release", ylab="Total lines of code (MLOC)\n")


# m3=nls(LOC ~ SSfpl(Number_days, a, b, c, d), data=first_3000)
# y=predict(m3, list(Number_days=x_bounds))

# lines(x_bounds, y, col="blue")

# m3=nls(LOC ~ a+(b-a)/(1+exp((c-Number_days)/d)), data=all_days,
#                  start=list(a=-3e+05, b=4e+6, c=2000, d=800))

m3=nls(MLOC ~ SSfpl(Number_days, a, b, c, d), data=all_days)
y=predict(m3, list(Number_days=x_bounds))

lines(x_bounds, y, col=pal_col[1])


