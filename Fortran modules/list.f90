module list
    implicit none

    private
    public :: Charlist, Constructor, Add, Get, GetAll, Insert, RemoveByNum, RemoveByName, getLocation, ContainsItem
    public :: sorter, GetSize, setter, Occurrences, RemoveDuplicates, GetAsIntegers, GetAsReals, RemoveNaN, Kind4, Kind1

    type CharList
        private
        character(len=1000, kind=4), dimension(:), allocatable :: list1
        character(len=1000, kind=4), dimension(:), allocatable :: list2
        integer :: lenght, alloc_stat, insertLoc, longest
        logical :: secondIsTheMain

        contains
            procedure :: create => Constructor
            procedure :: add => Add
            procedure :: get => Get
            procedure :: getAll => GetAll
            procedure :: insert => Insert
            procedure :: removeByNum => RemoveByNUm
            procedure :: removeByName => RemoveByName
            procedure :: indexOf => getLocation
            procedure :: containsItem => ContainsItem
            procedure :: sort => sorter
            procedure :: getSize => GetSize
            procedure :: set => setter
            procedure :: occurrences => Occurrences
            procedure :: RemoveDuplicates
            procedure :: getAsIntegers => GetAsIntegers
            procedure :: getAsReals => GetAsReals
            procedure :: removeNaN => RemoveNaN
            procedure :: kind4=>Kind4
            procedure :: kind1=>Kind1
    end type

    contains
        subroutine Constructor(this)
            class(CharList), intent(inout) :: this
            this%lenght = 8
            this%insertLoc = 1
            this%secondIsTheMain = .FALSE.
            this%longest=0
            allocate(this%list1(this%lenght), stat=this%alloc_stat)
            allocate(this%list2(this%lenght), stat=this%alloc_stat)


        end subroutine

        subroutine Add(this, value)
            class(CharList), intent(inout) :: this
            character(len=:, kind=4), allocatable :: value

            if (this%insertLoc == this%lenght) call doubleTheSize(this)

            if (this%secondIsTheMain.EQV..TRUE.) then
                this%list2(this%insertLoc) = value

            else
                this%list1(this%insertLoc) = value

            end if
            this%insertLoc = this%insertLoc + 1
            if (len(value)>this%longest) this%longest = len(value)


        end subroutine

        subroutine doubleTheSize(this)
            class(CharList), intent(inout) :: this
            integer :: num

            this%lenght = this%lenght*2

            if (this%secondIsTheMain.EQV..FALSE.) then
                this%secondIsTheMain = .TRUE.
                deallocate(this%list2)
                allocate(this%list2(this%lenght), stat=this%alloc_stat)
                this%list2(1:size(this%list1))=this%list1(1:size(this%list1))


            else
                this%secondIsTheMain = .FALSE.
                deallocate(this%list1)
                allocate(this%list1(this%lenght), stat=this%alloc_stat)
                this%list1(1:size(this%list2))=this%list2(1:size(this%list2))

            end if

        end subroutine

        function Get(this, num) result(item)
            class(CharList) :: this
            integer :: num
            character(len=:, kind=4), allocatable :: item

            if (this%secondIsTheMain.EQV..FALSE.) then
                item = trim(this%list1(num))
            else
                item = trim(this%list2(num))
            end if

        end function

        function GetAll(this) result(array)
            class(CharList) :: this
            integer :: alloc_stat
            character(len=this%longest, kind=4), dimension(:), allocatable :: array

            allocate(array(this%insertLoc), stat=alloc_stat)

            if (this%secondIsTheMain.EQV..TRUE.) then
                array = this%list2(1:this%insertLoc)
            else
                array = this%list1(1:this%insertLoc)
            end if
        end function

        subroutine Insert(this, value, location)
            class(CharList), intent(inout) :: this
            character(len=:, kind=4), allocatable :: value
            integer :: location

            if (this%insertLoc == this%lenght) call doubleTheSize(this)

            if (this%secondIsTheMain .EQV..TRUE.) then
                this%list2(location+1:size(this%list2)) = this%list2(location:size(this%list2)-1)
                this%list2(location) = value

            else
                this%list1(location+1:size(this%list1)) = this%list1(location:size(this%list1)-1)
                this%list1(location) = value

            end if
            this%insertLoc = this%insertLoc + 1
            if (len(value)>this%longest) this%longest = len(value)


        end subroutine

        subroutine RemoveByNum(this, location)
            class(CharList), intent(inout) :: this
            integer :: location

            if (this%secondIsTheMain .EQV..TRUE.) then
                this%list2(location:size(this%list2)-1) = this%list2(location+1:size(this%list2))
            else
                this%list1(location:size(this%list1)-1) = this%list2(location+1:size(this%list1))
            end if
            this%insertLoc = this%insertLoc - 1
            call checkLongest(this)

        end subroutine

        subroutine checkLongest(this)
            class(CharList), intent(inout) :: this
            integer :: num

            this%longest=0

            if (this%secondIsTheMain .EQV..TRUE.) then
                do num=1, this%insertLoc-1, 1
                    if (this%longest<len_trim(this%list2(num))) this%longest=len_trim(this%list2(num))
                end do
            else
                do num=1, this%insertLoc-1, 1
                    if (this%longest<len_trim(this%list1(num))) this%longest=len_trim(this%list1(num))
                end do
            end if

        end subroutine

    subroutine RemoveByName(this, value)
        class(CharList), intent(inout) :: this
        character(len=:, kind=4), allocatable :: value
        integer :: X

        X = getLocation(this, value)
        call RemoveByNum(this, X)


    end subroutine

    function getLocation(this, value) result(X)
        class(CharList), intent(inout) :: this
        character(len=:, kind=4), allocatable :: value
        integer :: X, num

        X = 0
        do num=1, this%insertLoc-1, 1
            if (this%secondIsTheMain.EQV..TRUE.) then
                if (trim(value) == trim(this%list2(num))) then
                    X = num
                    exit
                end if
            else
                if (trim(value) == trim(this%list1(num))) then
                    X = num
                    exit
                end if
            end if
        end do


    end function

    function ContainsItem(this, value) result(con)
        class(CharList), intent(inout) :: this
        character(len=:, kind=4), allocatable :: value
        logical :: con

        if (getLocation(this, value)/=0) then
            con = .TRUE.
        else
            con = .FALSE.
        end if
    end function


    subroutine sorter(this)
        class(CharList), intent(inout) :: this
        integer :: alloc, start, ind, num, modified, charindex, charvalue
        character(len=this%longest, kind=4) :: temp, temp2

        if (this%secondIsTheMain.EQV..TRUE.) then
            start=1
            do while (start<=size(this%list2))
                ind=start
                temp=""
                charindex=2147483647
                do num = start, size(this%list2), 1

                    if (ichar(this%list2(num)(1:1))>64 .AND. ichar(this%list2(num)(1:1))<91) then
                        charvalue = ichar(this%list2(num)(1:1))-55
                    else if (ichar(this%list2(num)(1:1))>96 .AND. ichar(this%list2(num)(1:1))<123) then
                        charvalue = ichar(this%list2(num)(1:1))-87
                    else if (ichar(this%list2(num)(1:1))>47 .AND. ichar(this%list2(num)(1:1))<58) then
                        charvalue = ichar(this%list2(num)(1:1))-48
                    else
                        charvalue = ichar(this%list2(num)(1:1))+60

                    end if

                    if (charvalue<charindex) then
                        charindex=charvalue
                        ind = num
                        temp= this%list2(num)

                    end if
                end do

                if (ind/=start) then
                    temp2 = this%list2(start)
                    this%list2(start) = temp
                    this%list2(ind) = temp2
                end if
                start=start+1
            end do
        else
            start=1
            do while (start<=size(this%list1))
                ind=start
                temp=""
                charindex=2147483647
                do num = start, size(this%list1), 1

                    if (ichar(this%list1(num)(1:1))>64 .AND. ichar(this%list1(num)(1:1))<91) then
                        charvalue = ichar(this%list1(num)(1:1))-55
                    else if (ichar(this%list1(num)(1:1))>96 .AND. ichar(this%list1(num)(1:1))<123) then
                        charvalue = ichar(this%list1(num)(1:1))-87
                    else if (ichar(this%list1(num)(1:1))>47 .AND. ichar(this%list1(num)(1:1))<58) then
                        charvalue = ichar(this%list1(num)(1:1))-48
                    else
                        charvalue = ichar(this%list1(num)(1:1))+60

                    end if

                    if (charvalue<charindex) then
                        charindex=charvalue
                        ind = num
                        temp= this%list1(num)

                    end if
                end do

                if (ind/=start) then
                    temp2 = this%list1(start)
                    this%list1(start) = temp
                    this%list1(ind) = temp2
                end if
                start=start+1
            end do
        end if
    end subroutine

    subroutine setter(this, value, num)
        class(CharList), intent(inout) :: this
        character(len=:, kind=4), allocatable :: value
        integer :: num

        if (this%secondIsTheMain.EQV..TRUE.) then
            this%list2(num) = value
        else
            this%list1(num) = value
        end if


    end subroutine

    function GetSize(this) result(s)
        class(CharList), intent(inout) :: this
        integer :: s

        s = this%insertLoc-1

    end function

    function Occurrences(this, value) result(o)
        class(CharList), intent(inout) :: this
        integer :: o, num
        character(len=:, kind=4), allocatable :: value

        o=0

        if (this%secondIsTheMain.EQV..TRUE.) then
            do num = 1, this%insertLoc-1, 1
                if (trim(this%list2(num))==trim(value)) o = o + 1
            end do
        else
            do num = 1, this%insertLoc-1, 1
                if (trim(this%list1(num))==trim(value)) o = o + 1
            end do
        end if
    end function

    subroutine RemoveDuplicates(this)
        class(CharList), intent(inout) :: this
        integer :: num

        if (this%secondIsTheMain.EQV..TRUE.) then
            do num = 1, this%insertLoc-1, 1
                do while(Occurrences(this, this%get(num))>1)
                    call RemoveByName(this, this%get(num))
                end do
            end do
        else
             do num = 1, this%insertLoc-1, 1
                do while(Occurrences(this, this%get(num))>1)
                    call RemoveByName(this, this%get(num))
                end do
            end do
        end if
    end subroutine

    function GetAsIntegers(this, sort) result(array)
        class(CharList), intent(inout) :: this
        integer, dimension(this%insertLoc-1) :: array
        integer :: num, ind, start, itemp, itemp2, charnum
        character(len=this%longest, kind=4) :: temp
        logical :: sort, isReal
        real :: tempreal

        isReal = .FALSE.

        do num=1, this%insertLoc-1, 1
            temp=this%get(num)
            do charnum=1, len(temp), 1
                if (temp(charnum:charnum)==this%kind4(".")) isReal = .TRUE.
            end do
            do charnum=1, len(temp), 1
                if ((ichar(temp(charnum:charnum))<48 .OR. ichar(temp(charnum:charnum))>57)&
                &.AND. temp(charnum:charnum)/=this%kind4(".")) isReal = .FALSE.
            end do
            if (isReal .EQV. .TRUE.) then
                read(temp, *) tempreal
                array(num) = int(tempreal)
            else

                read(temp, *) array(num)
            end if

        end do


        if (sort.EQV..TRUE.) then
            start=1
            do while (start<=size(array))
                ind=start
                itemp=2147483647
                do num = start, size(array), 1
                    if (array(num)<itemp) then
                        itemp = array(num)
                        ind = num
                    end if
                end do

                if (ind/=start) then
                    itemp2 = array(start)
                    array(start) = itemp
                    array(ind) = itemp2
                end if
                start=start+1

                end do
        end if

    end function

    function GetAsReals(this, sort) result(array)
        class(CharList), intent(inout) :: this
        real, dimension(this%insertLoc-1) :: array
        integer :: num, ind, start
        real :: itemp, itemp2
        character(len=this%longest, kind=4) :: temp
        logical :: sort

        do num=1, this%insertLoc-1, 1
            temp=this%get(num)
            read(temp, *) array(num)
        end do

        if (sort.EQV..TRUE.) then
            start=1
            do while (start<=size(array))
                ind=start
                itemp=2147483647
                do num = start, size(array), 1
                    if (array(num)<itemp) then
                        itemp = array(num)
                        ind = num
                    end if
                end do

                if (ind/=start) then
                    itemp2 = array(start)
                    array(start) = itemp
                    array(ind) = itemp2
                end if
                start=start+1

                end do
        end if

    end function

    subroutine RemoveNaN(this)
        class(CharList), intent(inout) :: this
        logical NaN
        integer :: num, charnum
        character(len=this%longest, kind=4) :: temp

        NaN = .TRUE.
        num = 1
        do while (num<this%insertLoc)
            temp = this%get(num)
            do charnum = 1, len_trim(temp), 1
                if (ichar(temp(charnum:charnum))>47 .AND. ichar(temp(charnum:charnum))<58) NaN = .FALSE.
            end do
            do charnum = 1, len_trim(temp), 1
            if ((ichar(temp(charnum:charnum))<48 .OR. ichar(temp(charnum:charnum))>57)&
                &.AND. temp(charnum:charnum)/=this%kind4(".")) NaN = .TRUE.
            end do

            if (NaN .EQV. .TRUE.) then
                call this%removeByNum(num)
            else
                num = num + 1
            end if
        end do


    end subroutine

    function Kind4(this, s) result(s2)
        class(CharList), intent(inout) :: this
        character(len=*, kind=1) :: s
        character(len=:, kind=4), allocatable :: s2
        s2=s
    end function

    function Kind1(this, s) result(s2)
        class(CharList), intent(inout) :: this
        character(len=*, kind=4) :: s
        character(len=:, kind=1), allocatable :: s2
        s2=s
    end function

end module
