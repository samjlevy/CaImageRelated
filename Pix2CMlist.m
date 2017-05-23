function Pix2Cm = Pix2CMlist ( RoomStr )
%Because it's stupid this wasn't done already

if ~isempty(RoomStr)
    switch RoomStr
        case '201b'
            Pix2Cm = 0.15;
        case '201a - 2015'
            Pix2Cm = 0.0874;
        case '201a'
            Pix2Cm = 0.0709;
    end
else
    Pix2Cm = input('No room found; do you know your Pix2Cm?')
end

end