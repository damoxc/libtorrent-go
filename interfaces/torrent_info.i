%{
#include <libtorrent/torrent_info.hpp>
%}

%ignore libtorrent::torrent_info::piece_range;
%ignore libtorrent::sanitize_append_path_element;
%ignore libtorrent::verify_encoding;

%include <libtorrent/torrent_info.hpp>
