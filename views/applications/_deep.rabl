attributes :id, :digest, :submitted_at, :created_at, :updated_at

child :citizens => :citizens do
  extends 'citizens/_deep'
end

child :spots => :spots do
  extends 'spots/_shallow'
end

child :entities => :entities do
  extends 'entities/_shallow'
end

child :reviewers => :reviewers do
  extends 'reviewers/_shallow'
end

child :fields => :fields do
  extends 'fields/_application'
end
