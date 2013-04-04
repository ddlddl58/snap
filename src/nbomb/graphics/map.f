c
c PROGRAM map.f
c Program map.f creates maps in the EMEP grid for operational bomb runs.
c-------------------------------------------------------------------------
c Modifications by Jerzy Bartnicki
c 03.11.2011: first version
c 04.06.2012: version 1 for operational bomb
c-------------------------------------------------------------------------
c
c
	implicit none
	integer imax 		! number of nodes in x-direction
	integer jmax 		! number of nodes in y-direction
	parameter (imax=170,jmax=133)
	real conc(imax,jmax)	! inst. concentration
	real depo(imax,jmax)	! deposition
	real dose(imax,jmax)	! time integrated concentration concentration
c
	integer icolor,istart,iend,jstart,jend,ilatlong	
	integer igrid,np,ng
	real rmin
	real rmax
	common/col/icolor
	common/corners/ istart,iend,jstart,jend
	common/ilatlong/ilatlong
	real cldep(7)		! depostion class limit
	real clcon(7)		! concentration class limit
	real cldose(7)		! time integrated concentration class limit
	real rc(8),gc(8),bc(8)	! color for each class
	data rc/0.6,0.5,0.8,1.0,1.0,1.0,1.0,0.6/
	data gc/0.6,1.0,1.0,1.0,0.8,0.4,0.0,0.0/
	data bc/1.0,0.5,0.1,0.0,0.0,0.0,0.0,0.0/
c
	character*80 filename
	character*80 psfile,infile
	character*120 title
c
	integer ngrid
	integer i,j,k,m
	real x,y,xg,yg
	real vol1,vol2,vol3,grid
	real lon,lat,snapcon,snapdep
c-----------------------------------
c
	icolor = 1
	igrid=0
	ilatlong=1
	istart=1
	jstart=1
	iend=170
	jend=133
c
c... initialization
c
	do i=1,imax
	do j=1,jmax
	   conc(i,j)=0.0
	   depo(i,j)=0.0
	   dose(i,j)=0.0
	enddo
	enddo
c	go to 999
c
c... 1) read, convert and plot data for concentration
c
	infile='grid_conc'
	write(*,*)
	write(*,*) 'Inst. concentration'
	call convert(infile,conc,ngrid)
	write(*,*) 'ngrid=', ngrid
c
	call range1(conc,rmin,rmax)
	write(*,'(''rmax='',e10.2)') rmax
	write(*,'(''rmin='',e10.2)') rmin
	data clcon/20,50,100,200,500,1000,2000/
	write(psfile,'(''snap_conc.eps'')') 
	write(title,'(''Inst. concentration (Bq/m3)'',
     &'' 27.09.2011 04UTC'')') 		       
	call map(psfile,title,conc,clcon,rc,gc,bc,rmin,rmax,igrid)
c
c... 2) read, convert and plot data for deposition
c
	infile='grid_depo'
	write(*,*)
	write(*,*) 'Deposition'
	call convert(infile,depo,ngrid)
	write(*,*) 'ngrid=', ngrid
c
	call range1(depo,rmin,rmax)
	write(*,'(''rmax='',e10.2)') rmax
	write(*,'(''rmin='',e10.2)') rmin
	data cldep/100,200,500,1000,2000,5000,10000/
	write(psfile,'(''snap_depo.eps'')') 
	write(title,'(''Total deposition (Bq/m2)'',
     &'' 27.09.2011 04UTC'')') 		       
	call map(psfile,title,depo,cldep,rc,gc,bc,rmin,rmax,igrid)
c
c... 3) read, convert and plot data for time integrated concentration
c
999	continue
	infile='grid_dose'
	write(*,*)
	write(*,*) 'Time integrated concentration'
	call convert(infile,dose,ngrid)
	write(*,*) 'ngrid=', ngrid
c
	call range1(dose,rmin,rmax)
	write(*,'(''rmax='',e10.2)') rmax
	write(*,'(''rmin='',e10.2)') rmin
	data cldose/100,200,500,1000,2000,5000,10000/
	write(psfile,'(''snap_dose.eps'')') 
	write(title,'(''Time integrated concentration (Bq h/m3)'',
     &'' 27.09.2011 04UTC'')') 		       
	call map(psfile,title,dose,cldose,rc,gc,bc,rmin,rmax,igrid)
c
	stop
	end
c
	subroutine convert(infile,con,ngrid)
c===========================================================================================
	implicit none
	integer imax 		! number of nodes in x-direction
	integer jmax 		! number of nodes in y-direction
	parameter (imax=170,jmax=133)
	real con(imax,jmax)	! time integrated concentrations or depositions in EMEP grid
	integer count(imax,jmax)	! number of non zero values in each grid
	integer ngrid		! No. of grid in the input file
	character*80 infile
	real x,y,lat,lon,val
	integer i,j,k
c--------------------------------------------------------------------------------------------
c
	write(*,*) '... subroutine convert ...'
	do i=1,imax
	do j=1,jmax
	   count(i,j)=0
	enddo
	enddo
c
	open(1,file=infile)
	rewind 1
	read(1,*) ngrid
	write(*,*) 'ngrid=',ngrid
	do k=1,ngrid
	  read(1,*) lon,lat,val
	  call gcxy(lat,lon,x,y)
	  i=int(x)
	  j=int(y)
c	  write(*,'(i5,4f10.4,2i5,e12.4)') 
c     &    k,lon,lat,x,y,i,j,val
	  con(i,j)=con(i,j)+val
	  count(i,j)= count(i,j)+1
	enddo
c
	do i=1,imax
	do j=1,jmax
	   if(count(i,j) .gt. 0) con(i,j)=con(i,j)/count(i,j)
	enddo
	enddo
c	
	return
	end
c
	subroutine latlong
	common/col/icolor
	common/corners/ istart,iend,jstart,jend
	xstart=real(istart-1)
	ystart=real(jstart-1)
	xend=real(iend)
	yend=real(jend)
c	write(*,*) '... subroutine latlong ...'
c.. rownolezniki
        if(icolor .eq. 1) write(2,*) ' 0 0 1 setrgbcolor'
	do ir=0,85,5
	   yg=0.0
	   xg=real(ir)
	   call gcxy(xg,yg,x,y)
	   if(x .lt. xstart) x=xstart
	   if(x .gt. xend) x=xend
	   if(y .lt. ystart) y=ystart
	   if(y .gt. yend) y=yend
           write(2,26) x,y
c          write(*,26) x,y
	   do i=1,3600
	     yg=real(i)*0.1
	     call gcxy(xg,yg,x,y)
	     if(x .lt. xstart) x=xstart
	     if(x .gt. xend) x=xend
	     if(y .lt. ystart) y=ystart
	     if(y .gt. yend) y=yend
             write(2,27) x,y
c             write(*,27) x,y
	   enddo
           write(2,*)' 1 setlinecap '
           write(2,*)' 1.5 setmiterlimit'
           write(2,*)' 0.02 s'
	enddo
c.. poludniki
	do ip=0,350,10
	   xg=0.0
	   yg=real(ip)
	   call gcxy(xg,yg,x,y)
	   if(x .lt. xstart) x=xstart
	   if(x .gt. xend) x=xend
	   if(y .lt. ystart) y=ystart
	   if(y .gt. yend) y=yend
           write(2,26) x,y
c          write(*,26) x,y
	   do i=1,850
	     xg=real(i)*0.1
	     call gcxy(xg,yg,x,y)
	     if(x .lt. xstart) x=xstart
	     if(x .gt. xend) x=xend
	     if(y .lt. ystart) y=ystart
	     if(y .gt. yend) y=yend
             write(2,27) x,y
c             write(*,27) x,y
	   enddo
           write(2,*)' 1 setlinecap '
           write(2,*)' 1.5 setmiterlimit'
           write(2,*)' 0.02 s'
	enddo


        if(icolor .eq. 1) write(2,*) ' 0 0 0 setrgbcolor'		
	return
26      format(f8.3,1x,f8.3,' i')
27      format(f8.3,1x,f8.3,' l')
	end

	subroutine geom
	common/col/icolor
c	write(*,*) '... subroutine geom ...'
        open(unit=3,file=
     &'/disk1/osparcom/2003/pc/geodata/cost.data')
        rewind 3
	read(3,*) iseg
	do 100 is=1,49
c	do 100 is=1,iseg
        read(3,*) iel
        read(3,'(2i6)') ig,jg
	xg = 0.01*real(ig)
	yg = 0.01*real(jg)
	call gcxy(xg,yg,x,y)
        write(2,26) x,y
        do 1 i= 2,iel
           read(3,'(2i6)') ig,jg
	   xg = 0.01*real(ig)
	   yg = 0.01*real(jg)
	   call gcxy(xg,yg,x,y)
           write(2,27) x,y
1       continue
        write(2,*) ' closepath '
        write(2,*) ' gsave'
c       if(icolor .ne. 0) then
c           write(2,*) ' 0.5 1 0.5 setrgbcolor '
c	   write(2,*) ' 1 1 0.8 setrgbcolor '
c	   write(2,*) ' 0.8 0.8 0.8  setrgbcolor '
c          write(2,*) ' fill'
c        else
c           gray = 0.75
c           write(2,'(f6.3,2x,12hsetgray fill)') gray
c        endif
        write(2,*) ' grestore'
        write(2,*)' 1 setlinecap '
        write(2,*)' 1.5 setmiterlimit'
        write(2,*) ' 0 0 0 setrgbcolor '
        write(2,*)' 0.1 s'
100	continue
  26   format(f8.3,1x,f8.3,' i')
  27   format(f8.3,1x,f8.3,' l')
	close (3)
	return
	end

	subroutine america
	common/col/icolor
c	write(*,*) '... subroutine america ...'
        open(unit=3,file=
     &'/disk1/osparcom/2003/pc/geodata/america.data')
        rewind 3
	read(3,*) iseg
	do 100 is=1,10
c	do 100 is=1,iseg
        read(3,*) iel
        read(3,'(2i6)') ig,jg
	xg = 0.01*real(ig)
	yg = 0.01*real(jg)
	call gcxy(xg,yg,x,y)
        write(2,26) x,y
        do 1 i= 2,iel
           read(3,'(2i6)') ig,jg
	   xg = 0.01*real(ig)
	   yg = 0.01*real(jg)
	   call gcxy(xg,yg,x,y)
           write(2,27) x,y
1       continue
        write(2,*) ' closepath '
        write(2,*) ' gsave'
        if(icolor .ne. 0) then
c           write(2,*) ' 0.5 1 0.5 setrgbcolor '
	   write(2,*) ' 0.8 0.8 0.8 setrgbcolor '
           write(2,*) ' fill'
	else
           gray = 0.7
           write(2,'(f6.3,2x,12hsetgray fill)') gray
        endif
        write(2,*) ' grestore'
        write(2,*)' 1 setlinecap '
        write(2,*)' 1.5 setmiterlimit'
        write(2,*) ' 0 0 0 setrgbcolor '
        write(2,*)' 0.05 s'
100	continue
  26   format(f8.3,1x,f8.3,' i')
  27   format(f8.3,1x,f8.3,' l')
	close (3)
	return
	end

	subroutine lakes
	common/col/icolor
c	write(*,*) '... subroutine lakes ...'
        open(3,file=
     &'/disk1/osparcom/2003/pc/geodata/lakes.data')
        rewind 3
	read(3,*) iseg
	do 100 is=1,17
c	do 100 is=1,iseg
        read(3,*) iel
        read(3,'(2i6)') ig,jg
	xg = 0.01*real(ig)
	yg = 0.01*real(jg)
	call gcxy(xg,yg,x,y)
        write(2,26) x,y
        do 1 i= 2,iel
           read(3,'(2i6)') ig,jg
	   xg = 0.01*real(ig)
	   yg = 0.01*real(jg)
	   call gcxy(xg,yg,x,y)
           write(2,27) x,y
1       continue
        write(2,*) ' closepath '
        write(2,*) ' gsave'
c        if(icolor .ne. 0) then
c           write(2,*) ' 0.6 1 1 setrgbcolor '
c	   write(2,*) ' 0.8 1 1 setrgbcolor '
c           write(2,*) ' 1 1 1 setrgbcolor ' 
c	   write(2,*) ' fill'
c	else
c           gray = 1.0
c           write(2,'(f6.3,2x,12hsetgray fill)') gray
c        endif
        write(2,*) ' grestore'
        write(2,*)' 1 setlinecap '
        write(2,*)' 1.5 setmiterlimit'
        write(2,*) ' 0 0 0 setrgbcolor '
        write(2,*)' 0.05  s'
100	continue
  26   format(f8.3,1x,f8.3,' i')
  27   format(f8.3,1x,f8.3,' l')
	close (3)
	return
	end

	subroutine bound
	common/col/icolor
c	write(*,*) '... subroutine bound ...'
        open(unit=3,file=
     &'/disk1/osparcom/2003/pc/geodata/boundaries.data')
        rewind 3
	read(3,*) iseg
        if(icolor .ne. 0) then
           write(2,*) ' 0 0 0 setrgbcolor '
        endif
	do 100 is=1,133
c	do 100 is=1,iseg
        read(3,*) iel
        read(3,'(2i6)') ig,jg
	xg = 0.01*real(ig)
	yg = 0.01*real(jg)
	call gcxy(xg,yg,x,y)
        write(2,26) x,y
        do 1 i= 2,iel
           read(3,'(2i6)') ig,jg
	   xg = 0.01*real(ig)
	   yg = 0.01*real(jg)
	   call gcxy(xg,yg,x,y)
           write(2,27) x,y
1       continue
        write(2,*)' 1 setlinecap '
        write(2,*)' 1.5 setmiterlimit'
        write(2,*)' 0.05 s'
100	continue
        write(2,*) ' 0 0 0 setrgbcolor '
  26   format(f8.3,1x,f8.3,' i')
  27   format(f8.3,1x,f8.3,' l')
	close (3)
	return
	end

	subroutine rivers
	common/col/icolor
c	write(*,*) '... subroutine rivers ...'
	if(icolor .eq. 0) return
        write(2,*) ' 0 0 1 setrgbcolor '
        open(3,file=
     &'/disk1/osparcom/2003/pc/geodata/rivers.data')
        rewind 3
	read(3,*) iseg
	do 100 is=1,33
c	do 100 is=1,iseg
        read(3,*) iel
        read(3,'(2i6)') ig,jg
	xg = 0.01*real(ig)
	yg = 0.01*real(jg)
	call gcxy(xg,yg,x,y)
        write(2,26) x,y
        do 1 i= 2,iel
           read(3,'(2i6)') ig,jg
	   xg = 0.01*real(ig)
	   yg = 0.01*real(jg)
	   call gcxy(xg,yg,x,y)
           write(2,27) x,y
1       continue
        write(2,*)' 1 setlinecap '
        write(2,*)' 1.5 setmiterlimit'
        write(2,*)' 0.05 s'
100	continue
        write(2,*) ' 0 0 0 setrgbcolor '
  26   format(f8.3,1x,f8.3,' i')
  27   format(f8.3,1x,f8.3,' l')
	close (3)
	return
	end
c
	subroutine gcxy(gx,gy,x,y)
c=================================
c..... defining the grid ........
c.. xp,yp = the north pole co-ordinate
c.. dist  = grid distance at 60 deg. north - meter -
c.. fi    = the meridian paralell to the y-axis
c.. radius = mean radius of earth  - meter -
c..
c.. an    = the grid distance pole - equator
c         = radius * ( 1 + sin(60deg))/dist
c.. gx - longitude
c.. gy - latitude
c
	common/corners/ istart,iend,jstart,jend
      xp = 43.
      yp = 121.
      dist = 50000.
      radius = 6370000.
      fi = -32.
      rad  = 3.1415927/180.      
      an = radius*( 1+sin(60.*rad))/dist
c
      vxr  = (90.+fi)*rad
      beta = sin(vxr)
      alfa = cos(vxr)
c
         glat = gx * rad
         glon = gy * rad
         rr   = an*cos(glat) / (1.+sin(glat))
         xr   = +rr * sin(glon)
         yr   = -rr * cos(glon)
         x = xr*beta - yr*alfa + xp - 0.5
         y = yr*beta + xr*alfa + yp - 0.5
c	 write(*,*) gx,gy,x,y
c	 if(x .gt. 170.0) stop
c	 if(y .gt. 133.0) stop
c	 if(x .lt. real(istart-1)) x = real(istart-1)
c	 if(x .gt. real(iend)) x = real(iend)
c	 if(y .lt. real(jstart-1)) y = real(jstart-1)
c	 if(y .gt. real(jend)) y = real(jend)
c
	return
	end

	subroutine grid
	common/corners/ istart,iend,jstart,jend
c        write(2,*) ' 1 0 0 setrgbcolor '
	y = real(jstart-1)
	y1 = real(jend)
	do i=istart,iend
	   x = real(i)
           write(2,26) x,y
           write(2,27) x,y1
           write(2,*)' 0.02 s'
	enddo
	x = real(istart-1)
	x1 = real(iend)
	do j=jstart,jend
	   y = real(j)
           write(2,26) x,y
           write(2,27) x1,y
           write(2,*)' 0.02 s'
	enddo
c        write(2,*) ' 0 0 0 setrgbcolor '
	return
  26   format(f8.3,1x,f8.3,' i')
  27   format(f8.3,1x,f8.3,' l')
        end

        subroutine frame(x,y,dx,dy)
        write(2,26) x,y
        x1 = x + dx
        y1 = y
        write(2,27) x1,y1
        x1 = x + dx
        y1 = y + dy
        write(2,27) x1,y1
        x1 = x
        y1 = y + dy
        write(2,27) x1,y1
        x1 = x
        y1 = y
        write(2,27) x1,y1
        write(2,*) ' closepath '
       write(2,*)' 0.2 s'
  26   format(f8.3,1x,f8.3,' i')
  27   format(f8.3,1x,f8.3,' l')
        return
        end
	
	subroutine sframe(x,y,dx,dy)
        write(2,26) x,y
        x1 = x + dx
        y1 = y
        write(2,27) x1,y1
        x1 = x + dx
        y1 = y + dy
        write(2,27) x1,y1
        x1 = x
        y1 = y + dy
        write(2,27) x1,y1
        x1 = x
        y1 = y
        write(2,27) x1,y1
        write(2,*) ' closepath '
       write(2,*)' 0.5 s'
  26   format(f8.3,1x,f8.3,' i')
  27   format(f8.3,1x,f8.3,' l')
        return
        end

	subroutine mframe
	common/corners/ istart,iend,jstart,jend
	write(2,'(2i6,'' i'')') istart-1,jstart-1
	write(2,'(2i6,'' l'')') iend,jstart-1
	write(2,'(2i6,'' l'')') iend,jend
	write(2,'(2i6,'' l'')') istart-1,jend
	write(2,'(2i6,'' l'')') istart-1,jstart-1	
        write(2,*)' closepath'
        write(2,*)' 0.05 s'
	return
	end

	subroutine marks
	common/corners/ istart,iend,jstart,jend
c X-axis:
	do i=istart,iend
c	   if(mod(i,10) .eq. 0 .or.
c     .	      i .eq. istart .or.
c     .        i .eq. iend) then
	      x = real(i) - 0.5
	      y = real(jstart-1)
              write(2,24) x,y
	      y = real(jstart)-1.5
              write(2,25) x,y
              write(2,*)' 0.02 s'
c	   endif
	enddo

c Y-axis:
	do j=jstart,jend
c	   if(mod(j,10) .eq. 0 .or.
c     .	      j .eq. jstart .or.
c     .        j .eq. jend) then
	      x = real(istart-1)
	      y = real(j) - 0.4
              write(2,24) x,y
	      x = real(istart)-1.5
              write(2,25) x,y
              write(2,*)' 0.02 s'
c	   endif
	enddo
c
c Draw grid numbers in x- and y-directions
c
c Get font:
       write(2,*)' /Helvetica-Narrow findfont 0.7 scalefont setfont'
c
c X-axis:
	do i=istart,iend
c	   if(mod(i,10) .eq. 0 .or.
c     .	      i .eq. istart .or.
c     .        i .eq. iend) then
	      y = real(jstart)-2.2
	      if(i .lt. 100) then
                 x = -0.9 + real(i)
                 write(2,'(2f8.3,2h i)') x,y
                 write(2,'(3h  (,i2,7h) show )') i-35
              else
                 x = -1.21 + real(i)
                 write(2,'(2f8.3,2h i)') x,y
                 write(2,'(3h  (,i3,7h) show )') i-35
              endif
c	   endif
	enddo
c
c... Y-axis
c
	do j=jstart,jend
c	   if(mod(j,10) .eq. 0 .or.
c     .	      j .eq. jstart .or.
c     .        j .eq. jend) then
              y = -0.6 + real(j)
              if(j .lt. 100) then
                 x = real(istart)-2.4
                 write(2,'(2f8.3,2h i)') x,y
                 write(2,'(3h  (,i2,7h) show )') j-11
              else
                 x = real(istart-2.7)
                 write(2,'(2f8.3,2h i)') x,y
                 write(2,'(3h  (,i3,7h) show )') j-11
              endif
c	   endif
	enddo             
	      
  34    continue
  24   format(f8.3,1x,f8.3,' m')
  25   format(f8.3,1x,f8.3,' l')
	return
	end

	subroutine cross
	common/col/icolor
        if(icolor .eq. 1) write(2,*) ' 1 0 0 setrgbcolor'
	x=41.5
	y=119.5
	write(2,26) x,y
c	write(*,26) x,y
	x=43.5
	y=121.5
	write(2,27) x,y
c	write(*,27) x,y
        write(2,*)' 1 setlinecap '
        write(2,*)' 1.5 setmiterlimit'
        write(2,*)' 1.0 s'
	x=43.5
	y=119.5
	write(2,26) x,y
c	write(*,26) x,y
	x=41.5
	y=121.5
	write(2,27) x,y
c	write(*,27) x,y
        write(2,*)' 1 setlinecap '
        write(2,*)' 1.5 setmiterlimit'
        write(2,*)' 1.0 s'
        if(icolor .eq. 1) write(2,*) ' 0 0 0 setrgbcolor'		
	return
26      format(f8.3,1x,f8.3,' i')
27      format(f8.3,1x,f8.3,' l')
	end


c
	subroutine map(psfile,title,nox,cl,rc,gc,bc,rmin,rmax,igrid)
	integer imax 		! number of nodes in x-direction
	integer jmax 		! number of nodes in y-direction
	parameter (imax=170,jmax=133)
	real nox(imax,jmax)  	! deposition of nitrogen in model coordinates
	common/col/icolor
	common/corners/ istart,iend,jstart,jend
	common/ilatlong/ilatlong
	real cl(7)		! depostion class
	real rc(8),gc(8),bc(8)	! color for each class
	character*80 psfile
	character*120 title
c
c... open ps file
	open(unit=2,file=psfile)
        rewind 2
c
c Write the header and some definitions:
c
        write(2,'(''%!PS-Adobe-3.0 EPSF-3.0'')')
	write(2,'(''%%BoundingBox: 0 0 790 580'')')
	write(2,'(''%BeginDocument: test.eps'')')

c
c Definitions ...
c Start new line and move to position x y:  ( x y i )
       write(2,*)'/i  { newpath moveto } bind def'
c Draw line to position x y:  ( x y l )
       write(2,*)'/l  { lineto } bind def'
c Only move to position x y. 
       write(2,*)'/m  { moveto } bind def'
c Define the width of the line.
       write(2,*)'/s  { setlinewidth stroke } bind def'
       write(2,*)'  '
c 'gsave' saves the printers previous setting, this is a nice
c thing to do to avoid screwing things up for the next printer
c user. Make sure you end the program with grestore!
c
       write(2,*)' gsave '
       write(2,*)'  '
c
c... white background
c
	write(2,'(''1 1 1 setrgbcolor 0 0 800 600 rectfill'')')
c
c Translating and scaling
c

          write(2,*)' 4 4 scale'
          write(2,*)' 2 2  translate'

c
c... Background inside model domain (for color plot)
c
	i1=istart
	i2=iend
	j1=jstart
	j2=jend
	write(2,'(2i6,'' i'')') istart-1,jstart-1
	write(2,'(2i6,'' l'')') iend,jstart-1
	write(2,'(2i6,'' l'')') iend,jend
	write(2,'(2i6,'' l'')') istart-1,jend
	write(2,'(2i6,'' l'')') istart-1,jstart-1
       write(2,*)' closepath'
       write(2,*) ' gsave'
       if(icolor .ne. 0) then
         write(2,*) 
     & ' 0.8 1 1 setrgbcolor fill grestore 0 0 0 setrgbcolor '
       endif
c
	call countries(1)
c
        write(2,*)' 0.05 s'
	write(2,*) ' 0.1 setlinewidth'
	write(2,*)' /Courier-Bold findfont 4 scalefont setfont'
	w=4.0
	h=8.0
	x=real(i2)+1.0
	xt=x+w+1.5
	do i=1,7
	   write(2,'(3f8.2,'' setrgbcolor'')') rc(i),gc(i),bc(i)
	   y=real(j1-1)+real(i-1)*h
	   yt=y+h-1.0
	   write(2,'(4f8.3,'' rectfill'')') x,y,w,h
	   write(2,*) ' 0 0 0 setrgbcolor '
	   write(2,'(4f8.3,'' rectstroke'')') x,y,w,h
	   write(2,'(2f8.2,2h i)') xt,yt
	   write(2,'(1x,'' ('',e7.1,'') show'')') cl(i)
c	   write(*,*) i,cl(i)
	enddo
c
	write(2,*)' /Courier-Bold findfont 4.5 scalefont setfont'
	write(2,*) ' 0 0 0 setrgbcolor '
	xt=real(i1)
	yt=real(j2)+1.5
	write(2,'(2f8.2,2h i)') xt,yt
	write(2,'(1x,'' ('',a120,'') show'')') title
	write(2,*) ' 0 0 0 setrgbcolor '
c
	i=8
	y=real(j1-1)+real(i-1)*h
	write(2,'(3f8.2,'' setrgbcolor'')') rc(i),gc(i),bc(i)
	write(2,'(4f8.3,'' rectfill'')') x,y,w,h
	write(2,*) ' 0 0 0 setrgbcolor '
	write(2,'(4f8.3,'' rectstroke'')') x,y,w,h
c	
	write(2,*) ' 0.1 setlinewidth'
	x1=x+w
	x2=x1+1.0
	do i=2,8
	   y=real(j1-1)+real(i-1)*h
	   write(2,'(2f8.2,2h i)') x1,y
	   write(2,'(2f8.2,2h l)') x2,y
	   write(2,*) ' stroke'	
	enddo
c
	w=1.0
	h=1.0
	do i=i1,i2
	do j=j1,j2
c	write(*,*) i,j,nox(i,j)
	   x=real(i-1)
	   y=real(j-1)
	      r=1
	      g=1
	      b=1
	   if(nox(i,j) .gt. 0 .and. nox(i,j) .lt. cl(1)) then
	      r=rc(1)
	      g=gc(1)
	      b=bc(1)
	   endif
	   if(nox(i,j) .ge. cl(1) .and. nox(i,j) .lt. cl(2)) then
	      r=rc(2)
	      g=gc(2)
	      b=bc(2)
	   endif
	   if(nox(i,j) .ge. cl(2) .and. nox(i,j) .lt. cl(3)) then
	      r=rc(3)
	      g=gc(3)
	      b=bc(3)
	   endif
	   if(nox(i,j) .ge. cl(3) .and. nox(i,j) .lt. cl(4)) then
	      r=rc(4)
	      g=gc(4)
	      b=bc(4)
	   endif
	   if(nox(i,j) .ge. cl(4) .and. nox(i,j) .lt. cl(5)) then
	      r=rc(5)
	      g=gc(5)
	      b=bc(5)
	   endif
	   if(nox(i,j) .ge. cl(5) .and. nox(i,j) .lt. cl(6)) then
	      r=rc(6)
	      g=gc(6)
	      b=bc(6)
	   endif
	   if(nox(i,j) .ge. cl(6) .and. nox(i,j) .lt. cl(7)) then
	      r=rc(7)
	      g=gc(7)
	      b=bc(7)
	   endif
	   if(nox(i,j) .gt. cl(7)) then
	      r=rc(8)
	      g=gc(8)
	      b=bc(8)
	   endif
	if(nox(i,j) .gt. 0.0) then
	   write(2,'(3f8.2,'' setrgbcolor'')') r,g,b
	   write(2,'(4f8.3,'' rectfill'')') x,y,w,h
c           write(*,*) i,j,nox(i,j)
	endif
	enddo
	enddo	
c
	write(2,*) ' 0 0 0 setrgbcolor'	
c
	call countries(0)	
	if(ilatlong .eq. 1) call latlong
c	call geom
c	call america
c	call lakes
c	call bound
c	call rivers
c
c... Model grid + frame
c
	call mframe
	if(igrid .ne. 0) call grid
c
c Draw Tin and tic  marks:
c
c	call marks
	if(igrid .ne. 0) call grid
c	
       write(2,*)'grestore'
       write(2,*)'showpage'
       write(2,'(''%%EndDocument'')')
       close (2)
c
c	write(*,*) '... end of map ...'  
c
        return
        end	
c
	subroutine range1(base,rmin,rmax)
	implicit none
	integer imax 		! number of nodes in x-direction
	integer jmax 		! number of nodes in y-direction
	parameter (imax=170,jmax=133)
	real base(imax,jmax)
	real rmin, rmax
	integer i,j,k
	rmax=-1.0e30
	rmin=1.0e30
	do i=1,imax
        do j=1,jmax
	   if(rmax .lt. base(i,j)) rmax=base(i,j)
	   if(base(i,j) .gt. 0.0 .and. rmin .gt. base(i,j)) 
     &     rmin=base(i,j)
        enddo
        enddo
c
	return 
	end
c
	subroutine countries(imode)
c       ===========================
c To create area and border lines of the countries within EMEP
c----------------------------------------------------------------
c
	implicit none
	real fi,la,fi0,la0		! geograpchical coordinates
	integer i,j,k,kold		! indexes
	integer ng		! number of grids in each country
	character*60 cname	! country name
	real x,y		! model coordinates
	integer icolor
	common/col/icolor
	integer istart,iend,jstart,jend	! corners of the model grid
	real xstart,xend,ystart,yend	! corners of the model grid	
	common/corners/ istart,iend,jstart,jend
	integer imode
c----------------------------------------------------------------
c
	open(1,file='/disk1/country/country.txt')
	rewind 1
c
	xstart=real(istart-1)
	ystart=real(jstart-1)
	xend=real(iend)
	yend=real(jend)
c	write(*,*) 'file opened'
	do i=1,251
c	write(*,*) 'i=',i
c	do i=1,14
	   read(1,*) ng, cname
c	 if(i .eq. 206)	then
	 if(i .eq. 3 .or.	! Afganistan
     &      i .eq. 4 .or.	! Algeria
     &      i .eq. 5 .or.	! Azerbaijan
     &      i .eq. 6 .or.	! Albania
     &      i .eq. 7 .or.	! Armenia
     &      i .eq. 8 .or.	! Andorra
     &      i .eq. 13 .or.	! Austria
     &      i .eq. 20 .or.	! Belgium
     &      i .eq. 20 .or.	! Bosnia
     &      i .eq. 28 .or.	! Byelarus
     &      i .eq. 32 .or.	! Bulgaria
     &      i .eq. 36 .or.	! Canada
     &      i .eq. 38 .or.	! Chad
     &      i .eq. 55 .or.	! Cyprus
     &      i .eq. 56 .or.	! Denmark
     &      i .eq. 62 .or.	! Egypt
     &      i .eq. 63 .or.	! Ireland
     &      i .eq. 65 .or.	! Estonia
     &      i .eq. 69 .or.	! Czech
     &      i .eq. 71 .or.	! Finland
     &      i .eq. 75 .or.	! Faroe
     &      i .eq. 78 .or.	! France
     &      i .eq. 82 .or.	! Georgia
     &      i .eq. 84 .or.	! Gibraltar
     &      i .eq. 87 .or.	! Grinland
     &      i .eq. 88 .or.	! Germany
     &      i .eq. 92 .or.	! Greece
     &      i .eq. 96 .or.	! Gaza
     &      i .eq. 101 .or.	! Croatia
     &      i .eq. 102 .or.	! Hungary
     &      i .eq. 103 .or.	! Iceland
     &      i .eq. 105 .or.	! Man
     &      i .eq. 108 .or.	! Iran
     &      i .eq. 109 .or.	! Israel
     &      i .eq. 110 .or.	! Italy
     &      i .eq. 112 .or.	! Irak
     &      i .eq. 114 .or.	! Jersey
     &      i .eq. 116 .or.	! Janc
     &      i .eq. 117 .or.	! Jordan
     &      i .eq. 127 .or.	! Kazakhstan
     &      i .eq. 129 .or.	! Lebanon
     &      i .eq. 130 .or.	! Latvia
     &      i .eq. 131 .or.	! Lithuania
     &      i .eq. 133 .or.	! Slovakia
     &      i .eq. 134 .or.	! Lihtenstein
     &      i .eq. 136 .or.	! Luxenbourg
     &      i .eq. 137 .or.	! Libya
     &      i .eq. 141 .or.	! Moldova
     &      i .eq. 147 .or.	! Macedonia
     &      i .eq. 148 .or.	! Monaco
     &      i .eq. 149 .or.	! Morocco
     &      i .eq. 153 .or.	! Malta
     &      i .eq. 156 .or.	! Montenegro
     &      i .eq. 163 .or.	! Niger
     &      i .eq. 166 .or.	! Netherland
     &      i .eq. 167 .or.	! Norway
     &      i .eq. 180 .or.	! Poland
     &      i .eq. 182 .or.	! Portugal
     &      i .eq. 189 .or.	! Romania
     &      i .eq. 192 .or.	! Russia
     &      i .eq. 194 .or.	! Saudi Arabia
     &      i .eq. 195 .or.	! St.
     &      i .eq. 201 .or.	! Slovenia
     &      i .eq. 203 .or.	! San
     &      i .eq. 206 .or.	! Spain
     &      i .eq. 207 .or.	! Serbia
     &      i .eq. 210 .or.	! Svalbard
     &      i .eq. 211 .or.	! Sweden
     &      i .eq. 213 .or.	! Syria
     &      i .eq. 214 .or.	! Switzerland
     &      i .eq. 224 .or.	! Tunisia
     &      i .eq. 225 .or.	! Turkay
     &      i .eq. 228 .or.	! Turkmenistanc
     &      i .eq. 231 .or.	! United Kingdom
     &      i .eq. 232 .or.	! Ukraine
     &      i .eq. 236 .or.	! Uzbekistan
     &      i .eq. 243)	then
c	    write(*,'(1x,2i10,2x,a10)') i,ng,cname
	    j=1
	    k=1
	    kold=1
	    read(1,*) fi,la
	    fi0=fi
	    la0=la
	    call gcxy(la,fi,x,y)
	    if (x .lt. 0.0) x=0.0
	    if (x .gt. 170.0) x=170.0
	    if (y .lt. 0.0) y=0.0
	    if (y .gt. 133.0) y=133.0
	    write(2,'(2f10.3,'' i'')') x,y
c	    write(*,'(2x,3i6,4f10.3,2x,a60)') 
c     &      kold,k,j,fi,la,x,y,cname
	    do j=2,ng
	       read(1,*) fi,la
	       if(fi .eq. fi0 .and. la .eq. la0) then
	         k=k+1
	         call gcxy(la,fi,x,y)
	         if(x .lt. xstart) x=xstart
	         if(x .gt. xend) x=xend
	         if(y .lt. ystart) y=ystart
	         if(y .gt. yend) y=yend
	         write(2,'(2f10.3,'' l'')') x,y
c	         write(*,'(2x,3i6,4f10.3,2x,a10)') 
c     &          kold, k,j,fi,la,x,y,cname
            write(2,*)' closepath'
            write(2,*) ' gsave'
            if(imode .eq. 1) then
               write(2,*) 
     &         ' 0.8 0.8 0.8 setrgbcolor fill grestore'
	       write(2,*) ' 0 0 0 setrgbcolor '
            endif
        write(2,*)' 1 setlinecap '
        write(2,*)' 1.5 setmiterlimit'
        write(2,*)' 0.05 s'
	       else
	         if(k .eq. kold) then
	         call gcxy(la,fi,x,y)
	         if(x .lt. xstart) x=xstart
	         if(x .gt. xend) x=xend
	         if(y .lt. ystart) y=ystart
	         if(y .gt. yend) y=yend
	         write(2,'(2f10.3,'' l'')') x,y
c	         write(*,'(2x,2i6,4f10.3,2x,a60)') 
c     &           k,j,fi,la,x,y,cname
	         else
	         call gcxy(la,fi,x,y)
	         if(x .lt. xstart) x=xstart
	         if(x .gt. xend) x=xend
	         if(y .lt. ystart) y=ystart
	         if(y .gt. yend) y=yend
		 fi0=fi
	         la0=la
	         kold=k
	         write(2,'(2f10.3,'' i'')') x,y
c	         write(*,'(2x,3i6,4f10.3,2x,a60)') 
c     &           kold,k,j,fi,la,x,y,cname
	         endif
	       endif
	    enddo
c            write(2,*)' closepath'
c            write(2,*) ' gsave'
c            if(icolor .ne. 0) then
c               write(2,*) 
c     &         ' 0 0 0 setrgbcolor fill grestore 0 0 0 setrgbcolor '
c            endif
c        write(2,*)' 1 setlinecap '
c        write(2,*)' 1.5 setmiterlimit'
c        write(2,*)' 0.05 s'
	 else
	   do j=1,ng
	      read(1,*) fi,la
	   enddo
	 endif
	enddo
	write(*,*) '... end of country ...'
c
	return
	end	
