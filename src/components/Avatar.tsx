interface AvatarProps {
  avatar: string | null;
  name: string;
}

export function Avatar({ avatar, name }: AvatarProps) {
  return (
    <>
      {avatar ? (
        <div className="mb-8">
          <img
            src={avatar}
            alt={name}
            className="w-32 h-32 rounded-full mx-auto shadow-lg border-4 border-white object-cover"
          />
        </div>
      ) : (
        <div className="mb-8">
          <div className="w-32 h-32 rounded-full mx-auto shadow-lg border-4 border-white bg-gradient-to-br from-purple-400 to-blue-400 flex items-center justify-center text-5xl text-white">
            {name.charAt(0).toUpperCase()}
          </div>
        </div>
      )}
    </>
  );
}

