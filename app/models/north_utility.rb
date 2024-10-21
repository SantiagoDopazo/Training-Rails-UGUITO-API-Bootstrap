class NorthUtility < Utility
  RANGES = {
    'short' => (0..50),
    'medium' => (51..100),
    'long' => (101..Float::INFINITY)
  }.freeze
end
