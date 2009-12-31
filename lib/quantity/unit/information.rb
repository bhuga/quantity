class Quantity
  class Unit
    ##
    # @see http://en.wikipedia.org/wiki/Mebibyte
    # @see http://en.wikipedia.org/wiki/Units_of_information
    class Information < Unit
      reference :bit, :bits

      add_unit :nibble, 4, :nibbles, :nybble, :nybbles
      add_unit :byte, 8, :bytes

      add_unit :kilobyte, 8 * 1000, :kb, :kilobytes
      add_unit :megabyte, 8 * (1000**2), :mb, :megabytes
      add_unit :gigabyte, 8 * (1000**3), :gb, :gigabytes
      add_unit :terabyte, 8 * (1000**4), :tb, :terabytes
      add_unit :petabyte, 8 * (1000**5), :pb, :petabytes
      add_unit :exabyte, 8 * (1000**6), :exabytes
      add_unit :zettabyte, 8 * (1000**7), :zettabytes
      add_unit :yottabyte, 8 * (1000**8), :yottabytes

      add_unit :kibibyte, 8 * 1024, :kibibytes, :KiB, :kib
      add_unit :mebibyte, 8 * (1024**2), :mebibytes, :MiB, :mib
      add_unit :gibibyte, 8 * (1024**3), :gibibytes, :GiB, :gib
      add_unit :tebibyte, 8 * (1024**4), :tebibytes, :TiB, :tib
      add_unit :pebibyte, 8 * (1024**5), :pebibytes, :PiB, :pib
      add_unit :exbibyte, 8 * (1024**6), :exbibytes, :EiB, :eib
      add_unit :zebibyte, 8 * (1024**7), :zebibytes, :ZiB, :zib
      add_unit :yobibyte, 8 * (1024**8), :yobibytes, :YiB, :yib
    end
  end
end
