class SouthUtility < Utility
  RANGES = {
    'short' => (0..60),
    'medium' => (61..120),
    'long' => (121..Float::INFINITY)
  }.freeze
end
