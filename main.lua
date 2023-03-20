
return function(Bitmap)
    local Image = {}

    local function FileSeek(Position)
        return Bitmap:sub(Position):byte()
    end

    local function MakeHeader(Offset)
        return tonumber(string.format("0x%x%x", FileSeek(Offset + 2), FileSeek(Offset + 1)))
    end

    local BitmapOffset = MakeHeader(0x0A)
    local Width, Height = MakeHeader(0x12), MakeHeader(0x16)
    local BitsPerPixel = MakeHeader(0x1C)
    local PacketSize = BitsPerPixel / 8

    for y = 1, Height do
        Image[y] = {}
    end

    local Index, Pixel = BitmapOffset, 0
    for _ = BitmapOffset, Width * PacketSize * Height + BitmapOffset - PacketSize, PacketSize do
        local Color, Alpha = {FileSeek(Index + 3), FileSeek(Index + 2), FileSeek(Index + 1)}, FileSeek(Index + 4) or 1

        Pixel = Pixel + 1
        Index = Index + PacketSize
        
        Image[(Pixel - 1) % Height + 1][Width - math.ceil(Pixel / Height) + 1] = {Color, Alpha and Alpha / 255 or 1}
    end

    return Image
end
