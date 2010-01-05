class Quantity
  class Unit
    ##
    # @see http://en.wikipedia.org/wiki/Mebibyte
    # @see http://en.wikipedia.org/wiki/Units_of_information
      
      add_unit :bit, :data, 1, :bits
      add_unit :nibble, :data, 4, :nibbles, :nybble, :nybbles
      add_unit :byte, :data, 8, :bytes

      add_unit :kilobyte, :data, 8 * 1000, :kb, :kilobytes
      add_unit :megabyte, :data, 8 * (1000**2), :mb, :megabytes
      add_unit :gigabyte, :data, 8 * (1000**3), :gb, :gigabytes
      add_unit :terabyte, :data, 8 * (1000**4), :tb, :terabytes
      add_unit :petabyte, :data, 8 * (1000**5), :pb, :petabytes
      add_unit :exabyte, :data, 8 * (1000**6), :exabytes
      add_unit :zettabyte, :data, 8 * (1000**7), :zettabytes
      add_unit :yottabyte, :data, 8 * (1000**8), :yottabytes

      add_unit :kibibyte, :data, 8 * 1024, :kibibytes, :KiB, :kib
      add_unit :mebibyte, :data, 8 * (1024**2), :mebibytes, :MiB, :mib
      add_unit :gibibyte, :data, 8 * (1024**3), :gibibytes, :GiB, :gib
      add_unit :tebibyte, :data, 8 * (1024**4), :tebibytes, :TiB, :tib
      add_unit :pebibyte, :data, 8 * (1024**5), :pebibytes, :PiB, :pib
      add_unit :exbibyte, :data, 8 * (1024**6), :exbibytes, :EiB, :eib
      add_unit :zebibyte, :data, 8 * (1024**7), :zebibytes, :ZiB, :zib
      add_unit :yobibyte, :data, 8 * (1024**8), :yobibytes, :YiB, :yib

  end
end
